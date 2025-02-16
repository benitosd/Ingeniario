class OutputReport < ApplicationRecord
  belongs_to :user
  has_many :output_report_stocks, dependent: :destroy
  has_many :stocks, through: :output_report_stocks
  accepts_nested_attributes_for :output_report_stocks, 
                            allow_destroy: true, 
                            reject_if: :all_blank
  validates :date, presence: true
  validates :reason, presence: true

  enum status: {
    pending: 0,    # Pendiente de aprobación
    approved: 1,   # Aprobado
    completed: 2,  # Completado (todos los items devueltos)
    cancelled: 3   # Cancelado
  }

  def approve!
    transaction do
      update!(status: :approved)
      output_report_stocks.each do |report_stock|
        stock = report_stock.stock
        stock.item_location&.destroy
        stock.create_item_location!(
          user: user,
          status: :assigned,
          assigned_at: Time.current,
          return_date: report_stock.return_date,
          notes: report_stock.notes
        )
      end
    end
  end
  searchable do
            text :user_id do
      user.try(:to_s)
    end
                integer :date
                text :reason
                integer :status
          end

  # Métodos adicionales
  def to_s
    super
  end
end
