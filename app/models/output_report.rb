class OutputReport < ApplicationRecord
  belongs_to :user
  has_many :output_report_stocks, dependent: :destroy
  has_many :stocks, through: :output_report_stocks
  has_many :input_reports, dependent: :destroy
  accepts_nested_attributes_for :output_report_stocks, 
                            allow_destroy: true, 
                            reject_if: :all_blank
  validates :date, presence: true
  validates :reason, presence: true
  validates :user, presence: true

  enum status: {
    pending: 0,
    approved: 1,
    cancelled: 2
  }, _default: :pending

  after_update :create_status_change_movement, if: :saved_change_to_status?

  def approve!
    transaction do
      update!(status: :approved)
      output_report_stocks.each do |report_stock|
        stock = report_stock.stock
        old_location = stock.item_location
        
        # Solo permitir asignar stocks que estén almacenados
        unless old_location&.in_storage?
          raise ActiveRecord::RecordInvalid.new(stock), 
                "El stock #{stock.reference} debe estar almacenado para poder ser asignado"
        end

        # Destruir la ubicación anterior
        old_location&.destroy

        # Crear nueva ubicación como asignado
        stock.create_item_location!(
          user: user,
          status: :assigned,
          assigned_at: Time.current,
          return_date: report_stock.return_date,
          notes: "Asignado en informe de salida ##{id} - #{report_stock.notes}"
        )
      end
    end
  end

  def status_text
    case status
    when 'pending'
      'Pendiente'
    when 'approved'
      'Aprobado'
    when 'cancelled'
      'Cancelado'
    else
      status
    end
  end

  searchable do
    text :user_info do
      [user&.code,user&.email].compact.join(' ')
    end
    string :id
    text :id
    string :status
    string :user do
      user&.code
    end
    
    time :date
    
    # Relaciones para búsqueda
    text :stock_references do
      output_report_stocks.map { |ors| ors.stock&.reference }
    end
    
    text :item_names do
      output_report_stocks.map { |ors| ors.stock&.item&.name }
    end
  end

  # Métodos adicionales
  def to_s
    super
  end

  def has_pending_returns?
    # Obtener los IDs de los stocks que ya han sido devueltos
    returned_stock_ids = input_reports.joins(:input_report_stocks)
                                    .where.not(status: :cancelled)
                                    .pluck('input_report_stocks.stock_id')

    # Verificar si hay stocks que aún no han sido devueltos
    # y que no estén marcados como rotos o desaparecidos
    stocks.joins(:item_location)
          .where(item_locations: { status: :assigned })
          .where.not(id: returned_stock_ids)
          .exists?
  end

  private

  def create_status_change_movement
    output_report_stocks.each do |report_stock|
      report_stock.stock_movements.create!(
        stock: report_stock.stock,
        user: user,
        action: 'output_report_status_change',
        status: status,
        notes: "Informe de salida cambió de estado a: #{status_text}"
      )
    end
  end
end
