

class Stock < ApplicationRecord
  belongs_to :item
  has_one :item_location, dependent: :destroy
  
  # Validaciones
  validates :reference, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :description, presence: true, length: { maximum: 255 }
  validates :entry_date, presence: true
  validates :active, inclusion: { in: [true, false] }
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  # Scope para búsqueda con Sunspot
  searchable do
    text :item_id do
      item.try(:to_s)
    end
    text :reference
    text :description
    boolean :active     # Cambiado de integer a boolean
    time :entry_date    # Cambiado de integer a time
  end
  
  # Métodos adicionales
  def to_s
    super
  end
  
  before_validation :generate_reference, on: :create
  
  def generate_qr_code
    parsed_data = JSON.parse(qr_code_data)
    reference = parsed_data["reference"]
    data = qr_code_data
            RQRCode::QRCode.new(reference, size: 6, level: :h)  # Puedes ajustar `size` y `level`
  end
  
  def generate_qr_code_svg
    generate_qr_code.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 8,    # Prueba con diferentes tamaños (6, 8, 11, etc.)
      standalone: true,
      use_path: true
    )
  end
  
  def generate_qr_code_png
    png = generate_qr_code.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 400
    )
    # Forzamos la codificación del resultado PNG a ASCII-8BIT (binary)
    png.to_s.force_encoding("ASCII-8BIT")
  end

  def current_location
    if item_location.present?
      case item_location.status
      when 'in_storage'
        "#{item_location.section.warehouse.name} - #{item_location.section.name}"
      when 'assigned'
        "Asignado a: #{item_location.user&.code || 'No asignado'}"
      when 'in_repair'
        "En reparación"
      when 'retired'
        "Retirado"
      else
        "Sin ubicación"
      end
    else
      "Sin ubicación"
    end
  end

  def qr_code_data
    {
      reference: reference,
      item_name: item.name,
      description: description,
      entry_date: entry_date.strftime('%d-%m-%Y'),
      status: active ? 'Activo' : 'Inactivo'
    }.to_json
  end
  
  private
  
 
  
  def generate_reference
    # Genera una referencia única si no se proporciona una
    return if reference.present?
    
    loop do
      # Formato: ITEM-[id del item]-[timestamp]-[random]
      self.reference = "ITEM-#{item_id}-#{Time.current.to_i}-#{SecureRandom.hex(2).upcase}"
      break unless Stock.exists?(reference: reference)
    end
  end
end