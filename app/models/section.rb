class Section < ApplicationRecord
  
    belongs_to :warehouse
    has_many :item_locations
    has_many :stocks, through: :item_locations
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

  def items_with_count
    stocks.joins(:item)
          .group('items.id, items.name')
          .select('items.*, COUNT(stocks.id) as stock_count')
  end

  def current_occupancy
    stocks.count
  end

  def available_capacity
    capacity - current_occupancy
  end
end
