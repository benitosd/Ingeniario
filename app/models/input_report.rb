class InputReport < ApplicationRecord
  
    belongs_to :output_report
    belongs_to :user
  
  # Definimos el enum usando strings en lugar de integers
  enum status: {
    'pending' => 'pending',
    'approved' => 'approved',
    'cancelled' => 'cancelled'
  }, _default: 'pending'

  # Luego las asociaciones
  has_many :input_report_stocks, dependent: :destroy
  has_many :stocks, through: :input_report_stocks

  # Y finalmente las validaciones
  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :user, presence: true
  validates :output_report, presence: true

  accepts_nested_attributes_for :input_report_stocks, 
                              allow_destroy: true, 
                              reject_if: :all_blank

  validate :can_approve, on: :approve

  # Scope para búsqueda con Sunspot
  searchable do
            text :output_report_id do
      output_report.try(:to_s)
    end
                text :user_id do
      user.try(:to_s)
    end
                time :date
                text :notes
                string :status
          end

  # Métodos adicionales
  def to_s
    super
  end

  after_update :create_status_change_movement, if: :saved_change_to_status?

  def approve!
    transaction do
      # Guardar el estado actual de cada stock antes de hacer cambios
      input_report_stocks.each do |input_report_stock|
        stock = input_report_stock.stock
        location = stock.item_location
        
        # Guardar el estado actual antes de cualquier cambio
        input_report_stock.update!(original_status: location&.status_text)
        
        # Actualizar la sección en todos los casos
        location.update!(
          section: input_report_stock.section,
          notes: input_report_stock.notes.presence || "Movido por informe de entrada ##{id}"
        )

        # Solo cambiar el estado a almacenado si está asignado
        if location.status == 'assigned'
          location.update!(status: :in_storage)
          Rails.logger.info "Stock #{stock.id} cambiado de asignado a almacenado"
        else
          Rails.logger.info "Stock #{stock.id} mantiene su estado actual: #{location.status}"
        end
      end

      # Actualizar el estado del informe al final
      update!(status: :approved)
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

  private

  def create_status_change_movement
    input_report_stocks.each do |report_stock|
      report_stock.stock_movements.create!(
        stock: report_stock.stock,
        user: user,
        action: 'input_report_status_change',
        status: status,
        notes: "Informe de entrada cambió de estado a: #{status_text}"
      )
    end
  end

  def can_approve
    input_report_stocks.each do |input_report_stock|
      stock = input_report_stock.stock
      
      # Verificar que el stock esté asignado y tenga una sección especificada
      unless stock.item_location&.assigned? && input_report_stock.section.present?
        errors.add(:base, "El stock #{stock.reference} debe estar asignado y tener una sección especificada para poder aprobar")
        return
      end
    end
  end
end
