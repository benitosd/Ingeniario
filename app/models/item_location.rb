class ItemLocation < ApplicationRecord
  include Trackable
  
  belongs_to :stock
  belongs_to :section, optional: true
  belongs_to :user
  has_one :item, through: :stock

  validates :status, presence: true
  validates :assigned_at, presence: true

  enum status: {
    'in_storage' => 0,      # almacenado
    'assigned' => 1,        # asignado
    'en_reparacion' => 2,   # en reparación
    'roto' => 3,           # roto
    'desaparecido' => 4    # desaparecido
  }

  # ... existing code ...

  def store!
    return false unless assigned? || en_reparacion?
    update!(
      status: :in_storage,
      notes: "#{notes} - Stock almacenado"
    )
  end

  def repair!
    return false unless assigned? || in_storage?
    update!(
      status: :en_reparacion,
      notes: "#{notes} - Stock enviado a reparación"
    )
  end

  def mark_as_broken!
    return false unless en_reparacion?
    update!(
      status: :roto,
      notes: "#{notes} - Stock marcado como roto"
    )
    stock.update!(active: false)
  end

  def mark_as_missing!
    return false unless assigned?
    update!(
      status: :desaparecido,
      notes: "#{notes} - Stock marcado como desaparecido"
    )
    stock.update!(active: false)
  end

  def return_to_storage!
    return false unless assigned? || en_reparacion?
    update!(
      status: :in_storage,
      notes: "#{notes} - Stock devuelto al almacén"
    )
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
    else
      status
    end
  end

  private
  
  def status_for_movement
    status
  end

  def movement_notes
    notes
  end
end