class OutputReportStock < ApplicationRecord
  include Trackable
  
  belongs_to :output_report
  belongs_to :stock

  validates :return_date, presence: true
  validate :stock_must_be_available
  validate :stock_must_be_located

  delegate :user, to: :output_report

  def status
    output_report.status
  end

  private

  def stock_must_be_available
    return unless stock
    if stock.item_location&.assigned?
      errors.add(:stock, "no está disponible para asignar")
    end
  end

  def stock_must_be_located
    return unless stock
    unless stock.item_location&.in_storage?
      errors.add(:stock, "debe estar ubicado en almacén")
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

  def to_s
    super
  end
end
