class Stock < ApplicationRecord
  belongs_to :item
  has_one :item_location, dependent: :destroy
  has_many :output_report_stocks, dependent: :restrict_with_error
  has_many :output_reports, through: :output_report_stocks
  has_many :input_report_stocks, dependent: :restrict_with_error
  has_many :input_reports, through: :input_report_stocks
  has_many :stock_movements, dependent: :destroy
  
  # Validaciones
  validates :reference, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :entry_date, presence: true
  validates :description, presence: true, length: { maximum: 255 }
  validates :active, inclusion: { in: [true, false] }
  validates :item_id, presence: true
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :available, -> { joins(:item_location).where(item_locations: { status: :in_storage }) }
  scope :assigned, -> { joins(:item_location).where(item_locations: { status: :assigned }) }
  scope :in_repair, -> { joins(:item_location).where(item_locations: { status: :en_reparacion }) }
  scope :broken, -> { joins(:item_location).where(item_locations: { status: :roto }) }
  scope :missing, -> { joins(:item_location).where(item_locations: { status: :desaparecido }) }
  scope :by_status, ->(status) {
    translated_status = translate_status(status)
    joins(:item_location).where(item_locations: { status: translated_status })
  }
  ESTADO_TRADUCCIONES = {
    'desaparecido' => 'missing',
    'in_storage' => 'storage',
    'assigned' => 'assigned',
    'en_reparacion' => 'repair',
    'roto' => 'broken',
    'entrada' => 'entrada'
  }.freeze

  ESTADO_TRADUCCIONES_INVERSO = ESTADO_TRADUCCIONES.invert.freeze

  # Scope para búsqueda con Sunspot
  searchable do
    text :reference
    text :description
    text :item_id do
      item&.name
    end
    
    string :item_location_status do
      item_location&.status
    end
    
    time :entry_date
    
    boolean :active
    
    string :status do
      if item_location&.status
        Rails.logger.debug "[SOLR INDEX] Estado original: #{item_location.status}"
        case item_location.status
        when 'in_storage'
          'in_storage'
        when 'assigned'
          'assigned'
        when 'en_reparacion'
          'en_reparacion'
        when 'roto'
          'roto'
        when 'desaparecido'
          'desaparecido'
        else
          item_location.status
        end
      end
    end

    # Agregar un boost al campo translated_status para mejorar la búsqueda
    
  end
  
  # Métodos adicionales
  def to_s
    "#{reference} - #{item.name}"
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

  def status
    item_location&.status || 'sin_ubicacion'
  end

  def status_text(status_param = nil)
    status_to_check = status_param || status
    case status_to_check.to_s
    when 'entrada'
      'Entrada'
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
    when 'sin_ubicacion'
      'Sin Ubicación'
    else
      status_to_check.to_s.humanize
    end
  end

  def available?
    item_location&.in_storage?
  end

  def assigned?
    item_location&.assigned?
  end

  def in_repair?
    item_location&.en_reparacion?
  end

  def broken?
    item_location&.roto?
  end

  def missing?
    item_location&.desaparecido?
  end

  def can_be_assigned?
    available? && active?
  end

  def can_be_repaired?
    assigned? && active?
  end

  def can_be_returned?
    (assigned? || in_repair?) && active?
  end

  def current_location
    return 'Sin ubicación' unless item_location
    if item_location.section
      "#{item_location.section.warehouse.name} - #{item_location.section.name}"
    else
      case status
      when 'assigned'
        "Asignado a #{item_location.user.email}"
      when 'en_reparacion'
        'En reparación'
      when 'roto'
        'Dado de baja (Roto)'
      when 'desaparecido'
        'Dado de baja (Desaparecido)'
      else
        'Ubicación desconocida'
      end
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
  
  def update_status_from_movements
    last_movement = stock_movements.order(created_at: :desc).first
    self.status = last_movement.status if last_movement
  end
  
  def status_class
    case status
    when 'entrada'
      'info'
    when 'in_storage'
      'success'
    when 'assigned'
      'card bg-special'
    when 'en_reparacion'
      'warning'
    when 'roto'
      'danger'
    when 'desaparecido'
      'danger'
    when 'sin_ubicacion'
      'secondary'
    else
      'secondary'
    end
  end
  
  def self.translate_status(status)
    Rails.logger.debug "[TRANSLATE] Traduciendo estado: #{status}"
    case status.to_s
    when 'broken'
      Rails.logger.debug "[TRANSLATE] Traducido a: roto"
      :roto
    when 'repair'
      Rails.logger.debug "[TRANSLATE] Traducido a: en_reparacion"
      :en_reparacion
    when 'missing'
      Rails.logger.debug "[TRANSLATE] Traducido a: desaparecido"
      :desaparecido
    when 'assigned'
      Rails.logger.debug "[TRANSLATE] Traducido a: assigned"
      :assigned
    when 'storage'
      Rails.logger.debug "[TRANSLATE] Traducido a: in_storage"
      :in_storage
    else
      Rails.logger.debug "[TRANSLATE] Sin traducción, usando: #{status}"
      status.to_s.to_sym
    end
  end

  def translate_status_to_external(status)
    ESTADO_TRADUCCIONES[status] if status
  end

  after_save :reindex_solr
  
  def self.debug_status(status)
    Rails.logger.debug "=== DEBUG STATUS ==="
    Rails.logger.debug "Buscando stocks con estado: #{status}"
    
    # Primero, veamos qué stocks tienen el estado 'desaparecido' en la base de datos
    stocks_db = Stock.joins(:item_location).where(item_locations: { status: 'desaparecido' })
    Rails.logger.debug "Stocks con estado 'desaparecido' en DB: #{stocks_db.count}"
    stocks_db.each do |stock|
      Rails.logger.debug "  Stock ##{stock.id}: #{stock.item_location.status}"
    end

    # Ahora hagamos la búsqueda en Solr
    search = Sunspot.search(Stock) do
      with(:translated_status, status)
    end
    
    Rails.logger.debug "Total encontrados en Solr: #{search.total}"
    search.results.each do |stock|
      Rails.logger.debug "Stock ##{stock.id}:"
      Rails.logger.debug "  - Estado original: #{stock.item_location&.status}"
      Rails.logger.debug "  - Estado traducido: #{stock.translated_status}"
    end
    Rails.logger.debug "===================="
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

  def reindex_solr
    Sunspot.index! self
  rescue => e
    Rails.logger.error "[SOLR ERROR] Error al reindexar: #{e.message}"
  end
end