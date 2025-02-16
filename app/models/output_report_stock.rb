class OutputReportStock < ApplicationRecord
  belongs_to :output_report
  belongs_to :stock

  validates :return_date, presence: true
  validate :stock_must_be_available

  private

  def stock_must_be_available
    return unless stock
    if stock.item_location&.assigned?
      errors.add(:stock, "no está disponible para asignar")
    end
  end
  searchable do
            text :output_report_id do
      output_report.try(:to_s)
    end
                text :stock_id do
      stock.try(:to_s)
    end
                integer :return_date
                text :notes
          end

  # Métodos adicionales
  def to_s
    super
  end
end
