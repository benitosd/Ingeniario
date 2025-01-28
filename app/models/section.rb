class Section < ApplicationRecord
  
    belongs_to :warehouse
    has_many :item_locations
  # Validaciones
      validates :name, presence: true, length: { maximum: 255 }
        validates :description, presence: true, length: { maximum: 255 }
            validates :capacity, presence: true, numericality: true
        validates :location_code, presence: true, numericality: { greater_than: 0 }, length: { maximum: 255 }
    
  # Scope para búsqueda con Sunspot
  searchable do
            text :name
                text :description
                text :warehouse_id do
      warehouse.try(:to_s)
    end
                integer :capacity
                text :location_code
          end

  # Métodos adicionales
  def to_s
    name
  end
end
