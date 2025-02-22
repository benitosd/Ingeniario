require 'faker'

def generate_unique_reference(item)
  loop do
    reference = "#{item.name[0..2].upcase}#{SecureRandom.hex(4).upcase}"
    break reference unless Stock.exists?(reference: reference)
  end
end

# Limpiar datos existentes
puts "Cleaning database..."
StockMovement.destroy_all
ItemLocation.destroy_all
InputReportStock.destroy_all
InputReport.destroy_all
OutputReportStock.destroy_all
OutputReport.destroy_all
Stock.destroy_all
Item.destroy_all
Section.destroy_all
Warehouse.destroy_all
Group.destroy_all
Family.destroy_all
User.destroy_all

# Crear usuario admin
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@example.com',
  password: '123456',
  code: 'ADMIN001'
)

# Crear familias
puts "Creating families..."
families = []
3.times do
  family = Family.create!(
    name: Faker::Commerce.department,
    description: Faker::Lorem.sentence(word_count: 10)
  )
  families << family
end

# Crear grupos con propiedades dinámicas
puts "Creating groups with properties..."
groups = []
families.each do |family|
  2.times do
    group = Group.create!(
      name: Faker::Commerce.material,
      description: Faker::Lorem.sentence(word_count: 8),
      family: family,
      properties: {
        "power" => "Power (in Watts)",
        "length" => "Length (in meters)",
        "color" => "Color"
      }
    )
    groups << group
  end
end

# Crear almacenes y secciones
puts "Creating warehouses and sections..."
warehouses = []
3.times do |w|
  warehouse = Warehouse.create!(
    name: Faker::Company.name + " Warehouse",
    description: Faker::Lorem.sentence(word_count: 10),
    location: Faker::Address.full_address,
    contact_info: Faker::PhoneNumber.phone_number
  )
  warehouses << warehouse

  # Crear secciones para cada almacén
  4.times do |i|
    Section.create!(
      warehouse: warehouse,
      name: "Section #{('A'..'Z').to_a[i]}",
      description: Faker::Lorem.sentence(word_count: 5),
      capacity: rand(50..200),
      location_code: "#{(w+1)}#{i+1}#{rand(100..999)}"
    )
  end
end

# Crear items y stocks
puts "Creating items and stocks..."
items = []
groups.each do |group|
  3.times do
    item_properties = {}
    group.properties.keys.each do |key|
      item_properties[key] = case key
        when "power"
          "#{rand(50..500)}W"
        when "length"
          "#{rand(1..10)}m"
        when "color"
          Faker::Color.color_name
        else
          "N/A"
      end
    end

    item = Item.create!(
      name: Faker::Commerce.product_name,
      description: Faker::Lorem.sentence(word_count: 15),
      group: group,
      properties: item_properties
    )
    items << item

    # Crear stocks para cada item con referencia única
    rand(2..4).times do |i|
      reference = generate_unique_reference(item)
      stock = Stock.create!(
        item: item,
        reference: reference,
        description: Faker::Lorem.sentence(word_count: 5),
        entry_date: Time.current,
        active: true
      )

      # Crear ubicación inicial para el stock
      section = Section.all.sample
      ItemLocation.create!(
        stock: stock,
        section: section,
        user: admin,
        status: :in_storage,
        assigned_at: Time.current,
        notes: "Ubicación inicial"
      )
    end
  end
end

puts "Creating stocks with different states..."
items.each do |item|
  # Stock en almacén (normal)
  3.times do
    reference = generate_unique_reference(item)
    stock = Stock.create!(
      item: item,
      reference: reference,
      description: Faker::Lorem.sentence(word_count: 5),
      entry_date: Time.current - rand(1..60).days,
      active: true
    )

    # Crear ubicación inicial (almacenado)
    section = Section.all.sample
    ItemLocation.create!(
      stock: stock,
      section: section,
      user: admin,
      status: :in_storage,
      assigned_at: Time.current,
      notes: "Ubicación inicial en almacén"
    )
  end

  # Stock en reparación
  reference = generate_unique_reference(item)
  stock = Stock.create!(
    item: item,
    reference: reference,
    description: Faker::Lorem.sentence(word_count: 5),
    entry_date: Time.current - rand(1..60).days,
    active: true
  )
  
  ItemLocation.create!(
    stock: stock,
    user: admin,
    status: :en_reparacion,
    assigned_at: Time.current - 5.days,
    notes: "Enviado a reparación por falla técnica"
  )

  # Stock roto
  reference = generate_unique_reference(item)
  stock = Stock.create!(
    item: item,
    reference: reference,
    description: Faker::Lorem.sentence(word_count: 5),
    entry_date: Time.current - rand(1..60).days,
    active: false
  )
  
  ItemLocation.create!(
    stock: stock,
    user: admin,
    status: :roto,
    assigned_at: Time.current - 10.days,
    notes: "Daño irreparable durante uso"
  )

  # Stock desaparecido
  reference = generate_unique_reference(item)
  stock = Stock.create!(
    item: item,
    reference: reference,
    description: Faker::Lorem.sentence(word_count: 5),
    entry_date: Time.current - rand(1..60).days,
    active: false
  )
  
  ItemLocation.create!(
    stock: stock,
    user: admin,
    status: :desaparecido,
    assigned_at: Time.current - 15.days,
    notes: "No retornado después de préstamo"
  )
end

# Crear movimientos históricos para los stocks
puts "Creando historial de movimientos para stocks..."

Stock.find_each do |stock|
  # Asegurarnos de que el stock tiene una ubicación
  item_location = stock.item_location || stock.create_item_location!(
    user: User.all.sample,
    status: 'in_storage',
    assigned_at: stock.created_at,
    section: Section.all.sample
  )

  # Movimiento de creación
  StockMovement.create!(
    stock: stock,
    user: User.all.sample,
    action: 'created',
    status: 'in_storage',
    notes: "Stock creado inicialmente",
    created_at: stock.created_at,
    trackable: item_location
  )

  # Generar entre 2 y 5 movimientos aleatorios por stock
  rand(2..5).times do
    # Elegir un estado aleatorio
    new_status = StockMovement::STATUSES.keys.sample
    
    # Determinar una fecha aleatoria entre la creación del stock y ahora
    movement_date = rand(stock.created_at..Time.current)

    # Crear el movimiento
    StockMovement.create!(
      stock: stock,
      user: User.all.sample,
      action: 'status_changed',
      status: new_status,
      trackable: item_location,
      notes: case new_status
             when 'in_storage'
               "Stock almacenado en #{item_location.section&.name || 'almacén'}"
             when 'assigned'
               "Stock asignado para uso en proyecto"
             when 'en_reparacion'
               "Stock enviado a reparación por mantenimiento"
             when 'roto'
               "Stock marcado como roto - No reparable"
             when 'desaparecido'
               "Stock reportado como desaparecido"
             end,
      created_at: movement_date,
      updated_at: movement_date
    )
  end

  # Si el stock está inactivo, añadir un movimiento final
  unless stock.active?
    StockMovement.create!(
      stock: stock,
      user: User.all.sample,
      action: 'status_changed',
      status: ['roto', 'desaparecido'].sample,
      trackable: item_location,
      notes: "Stock dado de baja del inventario",
      created_at: Time.current - rand(1..30).days
    )
  end
end

puts "Historial de movimientos creado exitosamente!"

# Crear informes de salida y entrada
puts "Creating output and input reports..."
10.times do |i|
  puts "=== Creating output report #{i + 1} ==="
  
  # Crear informe de salida
  output_report = OutputReport.create!({
    user: admin,
    date: Time.current - rand(1..60).days,
    reason: Faker::Lorem.sentence(word_count: 5),
    status: :pending
  })
  
  puts "Created output report with status: #{output_report.status}"

  # Asignar stocks al informe de salida
  available_stocks = Stock.joins(:item_location)
                         .where(item_locations: { status: :in_storage })
                         .sample(rand(2..4))
  
  puts "Found #{available_stocks.size} available stocks"

  available_stocks.each do |stock|
    puts "Creating OutputReportStock for stock #{stock.id}"
    OutputReportStock.create!(
      output_report: output_report,
      stock: stock,
      notes: Faker::Lorem.sentence(word_count: 3),
      return_date: Time.current + rand(1..30).days
    )
  end

  # Aprobar algunos informes de salida
  if rand < 0.5 && output_report.output_report_stocks.any?
    puts "Approving output report #{output_report.id}"
    output_report.approve!
    puts "Output report approved, new status: #{output_report.status}"

    # Crear informes de entrada para algunos stocks
    if rand < 0.7
      puts "Creating input report for approved output report #{output_report.id}"
      input_report = InputReport.new(
        output_report: output_report,
        user: admin,
        date: output_report.date + rand(1..30).days,
        notes: Faker::Lorem.sentence(word_count: 5),
        status: 'pending'
      )

      if input_report.valid?
        input_report.save!
        input_report.reload
        puts "Input report created successfully with status: #{input_report.status}"
      else
        puts "Input report validation errors:"
        input_report.errors.full_messages.each do |error|
          puts "  - #{error}"
        end
        raise "Failed to create input report"
      end

      # Seleccionar stocks que estén asignados
      return_stocks = output_report.stocks.joins(:item_location)
                                 .where(item_locations: { status: :assigned })
                                 .sample(rand(1..output_report.stocks.count))
      
      puts "Selected #{return_stocks.size} assigned stocks for return"

      return_stocks.each do |stock|
        puts "\n=== Processing stock #{stock.id} ==="
        puts "Current stock location status: #{stock.item_location.status}"
        
        begin
          puts "\nCreating InputReportStock..."
          input_report_stock = InputReportStock.new(
            input_report: input_report,
            stock: stock,
            section: Section.first,
            notes: Faker::Lorem.sentence(word_count: 3)
          )

          if input_report_stock.valid?
            puts "InputReportStock is valid"
            input_report_stock.save!
            puts "Successfully created InputReportStock"
          else
            puts "InputReportStock validation errors:"
            input_report_stock.errors.full_messages.each do |error|
              puts "  - #{error}"
            end
          end
        rescue => e
          puts "\n!!! ERROR !!!"
          puts "Error class: #{e.class}"
          puts "Error message: #{e.message}"
          puts "Stock status: #{stock.item_location&.status}"
          puts "Backtrace:"
          puts e.backtrace[0..5]
        end
      end

      # Aprobar algunos informes de entrada
      if rand < 0.5 && input_report.input_report_stocks.any?
        puts "Approving input report #{input_report.id}"
        input_report.approve!
      end
    end
  end
end

puts "Seeding completed successfully!"