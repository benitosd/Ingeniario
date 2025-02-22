class StockMovement < ApplicationRecord
  belongs_to :stock
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  validates :action, presence: true
  validates :status, presence: true
  # validates :notes, presence: true
  validates :trackable, presence: true

  # Definimos las acciones como strings
  ACTIONS = {
    'created' => 'created',
    'updated' => 'updated',
    'deleted' => 'deleted',
    'status_change' => 'status_change',
    'status_changed' => 'status_changed',
    'output_report_stock' => 'output_report_stock',
    'input_report_stock' => 'input_report_stock',
    'output_report_status_change' => 'output_report_status_change',
    'input_report_status_change' => 'input_report_status_change',
    'assigned' => 'assigned',
    'stored' => 'stored',
    'repaired' => 'repaired',
    'broken' => 'broken',
    'location_change' => 'location_change'
  }

  # Definimos los estados como strings
  STATUSES = {
    'in_storage' => 'in_storage',
    'assigned' => 'assigned',
    'en_reparacion' => 'en_reparacion',
    'roto' => 'roto',
    'desaparecido' => 'desaparecido',
    'pending' => 'pending',
    'approved' => 'approved',
    'cancelled' => 'cancelled'
  }

  def self.actions
    ACTIONS
  end

  def self.statuses
    STATUSES
  end

  def action_text
    case action
    when 'created'
      'Creado'
    when 'updated'
      'Actualizado'
    when 'deleted'
      'Eliminado'
    when 'status_change', 'status_changed'
      'Cambio de estado'
    when 'output_report_stock'
      'Agregado a informe de salida'
    when 'input_report_stock'
      'Agregado a informe de entrada'
    when 'output_report_status_change'
      'Informe de salida actualizado'
    when 'input_report_status_change'
      'Informe de entrada actualizado'
    when 'assigned'
      'Asignado'
    when 'stored'
      'Almacenado'
    when 'repaired'
      'Enviado a reparación'
    when 'broken'
      'Marcado como roto'
    when 'location_change'
      if trackable_type == 'OutputReportStock'
        'Agregado a informe de salida'
      elsif trackable_type == 'InputReportStock'
        'Agregado a informe de entrada'
      else
        'Cambio de ubicación'
      end
    else
      "Desconocido (#{action})"
    end
  end

  def status_text
    case status
    when 'in_storage'
      'Almacenado'
    when 'assigned'
      'Asignado'
    when 'en_reparacion'
      'En Reparación'
    when 'roto'
      'Roto'
    when 'desaparecido'
      'Desaparecido'
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

  def status_class
    case status
    when 'in_storage'
      'success'
    when 'assigned'
      'card bg-special'
    when 'en_reparacion'
      'warning'
    when 'roto', 'desaparecido', 'cancelled'
      'danger'
    when 'pending'
      'info'
    when 'approved'
      'success'
    else
      'secondary'
    end
  end

  def related_record_path
    case trackable_type
    when 'OutputReportStock'
      trackable.output_report
    when 'InputReportStock'
      trackable.input_report
    when 'ItemLocation'
      trackable.stock
    else
      nil
    end
  end

  def movement_description
    case trackable_type
    when 'OutputReportStock'
      output_report = trackable.output_report
      "Informe de salida ##{output_report.id} - #{status_text}"
    when 'InputReportStock'
      input_report = trackable.input_report
      "Informe de entrada ##{input_report.id} - #{status_text}"
    when 'ItemLocation'
      "#{action_text} - #{status_text}"
    else
      notes
    end
  end

  searchable do
    text :stock_id do
      stock.try(:to_s)
    end
    text :user_id do
      user.try(:to_s)
    end
    string :action
    string :status
    text :notes
    time :created_at
  end
end 