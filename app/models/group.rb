class Group < ApplicationRecord
  
belongs_to :family
has_many :items, dependent: :destroy
has_one_attached :photo  
# Validaciones
validates :name, presence: true, length: { maximum: 255 }
validates :description, presence: true, length: { maximum: 255 }
validate :validate_properties_format
validates :properties, presence: true, if: -> { properties != {} }
  
        
# Scope para búsqueda con Sunspot
searchable do
  text :name
  text :description
  string :description_for_sort do
    description # Asegúrate de que este valor sea único
  end
  string :name_for_sort do
    name # Asegúrate de que este valor sea único
  end
  text :family_id do
  family.try(:to_s)
 end
end

# Métodos adicionales
def to_s
  name
end
def property_keys
  properties&.keys || []
end

private

  def validate_properties_format
    errors.add(:properties, "must be a valid JSON object") unless properties.is_a?(Hash)
  end
end