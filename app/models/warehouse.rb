class Warehouse < ApplicationRecord
  has_one_attached :image
  
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

  def total_items
    sections.sum { |section| section.item_locations.count }
  end

  # Procesar la imagen antes de guardar
  after_commit :resize_image, on: [:create, :update], if: :image_attached?

  private

  def image_attached?
    image.attached?
  end

  def resize_image
    return unless image.attached?
    
    image.variant(resize_to_limit: [800, 600]).processed
  end
end
