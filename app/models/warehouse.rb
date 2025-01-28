class Warehouse < ApplicationRecord
  
    has_many :sections, dependent: :destroy
    has_many :item_locations, through: :sections
    
     
  
  # Validaciones
      validates :name, presence: true, length: { maximum: 255 }
        validates :description, presence: true, length: { maximum: 255 }
        validates :location, presence: true, length: { maximum: 255 }
        validates :contact_info, presence: true, length: { maximum: 255 }
    
  # Scope para búsqueda con Sunspot
  searchable do
            text :name
                text :description
                text :location
                text :contact_info
          end

  # Métodos adicionales
  def to_s
    name
  end
end
