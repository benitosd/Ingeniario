module Trackable
  extend ActiveSupport::Concern

  included do
    has_many :stock_movements, as: :trackable, dependent: :destroy
    after_create :create_movement
    after_update :create_update_movement, if: :status_changed?
  end

  private

  def create_movement
    return unless stock.present? && user.present?

    action_type = case self.class.name
    when 'OutputReportStock'
      'output_report_stock'
    when 'InputReportStock'
      'input_report_stock'
    when 'ItemLocation'
      'location_change'
    end

    stock_movements.create!(
      stock: stock,
      user: user,
      action: action_type,
      status: status_for_movement,
      notes: movement_notes
    )
  end

  def create_update_movement
    stock_movements.create!(
      stock: stock,
      user: user,
      action: 'status_change',
      status: status_for_movement,
      notes: "Estado actualizado a: #{status_text}"
    )
  end

  def status_for_movement
    case self.class.name
    when 'OutputReportStock'
      output_report&.status || 'pending'
    when 'InputReportStock'
      input_report&.status || 'pending'
    when 'ItemLocation'
      status
    else
      'pending'
    end
  end

  def movement_notes
    case self.class.name
    when 'OutputReportStock'
      "Stock agregado al informe de salida ##{output_report.id} - #{notes}"
    when 'InputReportStock'
      "Stock agregado al informe de entrada ##{input_report.id} - #{notes}"
    when 'ItemLocation'
      notes
    else
      'Movimiento registrado'
    end
  end

  def status_text
    case status_for_movement
    when 'pending'
      'Pendiente'
    when 'approved'
      'Aprobado'
    when 'cancelled'
      'Cancelado'
    else
      status_for_movement
    end
  end

  def status_changed?
    case self.class.name
    when 'InputReportStock'
      input_report.saved_change_to_status?
    when 'OutputReportStock'
      output_report.saved_change_to_status?
    else
      saved_change_to_status?
    end
  end
end 