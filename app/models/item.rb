class Item < ApplicationRecord
has_many :stocks, dependent: :destroy  
belongs_to :group
has_one_attached :photo
before_validation :initialize_propierty

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
  text :group_id do
  group.try(:to_s)
  end
end

def validate_properties_format
  unless properties.is_a?(Hash)
    errors.add(:properties, "must be a valid JSON object")
  end
end
  # Métodos adicionales
  def to_s
    name
  end
  private

  def initialize_propierty
    return unless group

    # Inicializa valores de propiedades basados en las claves del grupo
    self.properties ||= {}
    group.property_keys.each do |key|
      self.properties[key] ||= nil
    end
  end
end

def validate_properties_keys
  group_keys = group.properties.values
  invalid_keys = properties.keys - group_keys

  unless invalid_keys.empty?
    errors.add(:properties, "contain invalid keys: #{invalid_keys.join(', ')}")
  end
end