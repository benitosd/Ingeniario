class ItemLocation < ApplicationRecord
  
  belongs_to :stock
  belongs_to :section, optional: true
  belongs_to :user, optional: true
  has_one :item, through: :stock
  validates :status, presence: true
  validates :assigned_at, presence: true
  validates :section, presence: true, if: :in_storage?
  validates :user, presence: true, if: :assigned?
  validates :return_date, presence: true, if: :assigned?
  
  enum status: {
    in_storage: 0,     # En almacén
    assigned: 1,       # Asignado a usuario
    in_repair: 2,      # En reparación
    retired: 3         # Retirado/dado de baja
  }
    
  # Scope para búsqueda con Sunspot
  searchable do
            text :item_id do
      item.try(:to_s)
    end
                text :section_id do
      section.try(:to_s)
    end
                text :user_id do
      user.try(:to_s)
    end
                integer :status
                integer :assigned_at
                integer :return_date
                text :notes
          end

  # Métodos adicionales
  def to_s
    super
  end
  private
  
  def assigned_to_user?
    status == 'assigned'
  end
  
  def validate_location
    if status == 'in_storage' && section.nil?
      errors.add(:section, "debe especificarse cuando el item está en almacén")
    elsif status == 'assigned' && user.nil?
      errors.add(:user, "debe especificarse cuando el item está asignado")
    end
  end
end
