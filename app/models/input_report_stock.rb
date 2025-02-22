class InputReportStock < ApplicationRecord
  include Trackable
  
  belongs_to :input_report
  belongs_to :stock
  belongs_to :section, optional: true
  
  delegate :user, to: :input_report

  # Validaciones
  validates :stock_id, presence: true
  validates :section_id, presence: true
    
  validate :stock_belongs_to_output_report
  validate :stock_is_not_assigned, on: :create
  validate :output_report_is_approved

  # Scope para búsqueda con Sunspot
  searchable do
    text :input_report_id do
      input_report.try(:to_s)
    end
    text :stock_id do
      stock.try(:to_s)
    end
    text :section_id do
      section.try(:to_s)
    end
    text :notes
  end

  def to_s
    super
  end

  def status
    input_report&.status
  end

  def status=(value)
    input_report.status = value if input_report
  end

  def status_for_movement
    input_report&.status || 'pending'
  end

  private

  def stock_belongs_to_output_report
    return unless stock && input_report&.output_report

    unless input_report.output_report.output_report_stocks.exists?(stock: stock)
      errors.add(:stock, "no pertenece al informe de salida")
    end
  end

  def stock_is_not_assigned
    return unless stock
    return if section.present? # Permitir si se especifica una sección

    if stock.item_location.present? && stock.item_location.assigned?
      errors.add(:stock, "ya está asignado a una ubicación y no se ha especificado una nueva sección")
    end
  end

  def output_report_is_approved
    unless input_report&.output_report&.approved?
      errors.add(:base, "el informe de salida debe estar aprobado")
    end
  end
end
