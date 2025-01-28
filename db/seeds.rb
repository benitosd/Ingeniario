require 'faker'

# Limpiar datos existentes
puts "Cleaning database..."
ItemLocation.destroy_all
Stock.destroy_all
Item.destroy_all
Section.destroy_all
Warehouse.destroy_all
Group.destroy_all
Family.destroy_all

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
      location_code: "#{(w+1)}#{i+1}#{rand(100..999)}" # Número de 6 dígitos
    )
  end
end

# Crear ítems dentro de cada grupo usando las propiedades del grupo
puts "Creating items and stocks..."
groups.each do |group|
  3.times do
    # Crear un hash de propiedades basado en las claves del grupo
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

    # Crear el ítem con las propiedades generadas
    item = Item.create!(
      name: Faker::Commerce.product_name,
      description: Faker::Lorem.sentence(word_count: 15),
      group: group,
      properties: item_properties
    )

    # Adjuntar una foto aleatoria a cada ítem
    item.photo.attach(
      io: File.open(Rails.root.join("app/assets/images/default-item.jpg")),
      filename: "default-item.jpg",
      content_type: "image/jpeg"
    )

    # Crear stocks para cada ítem
    rand(2..5).times do
      stock = Stock.create!(
        item: item,
        description: Faker::Lorem.sentence(word_count: 5),
        active: [true, true, true, false].sample, # 75% de probabilidad de estar activo
        entry_date: Faker::Date.between(from: 6.months.ago, to: Date.today)
      )

      # Crear ubicación para el stock si está activo
      if stock.active?
        # Elegir un estado aleatorio pero con más probabilidad de estar en almacén
        status = ['in_storage', 'in_storage', 'in_storage', 'assigned', 'in_repair'].sample
        
        # Parámetros base para ItemLocation
        item_location_params = {
          stock_id: stock.id,
          status: status,
          assigned_at: Faker::Date.between(from: 3.months.ago, to: Date.today),
          notes: Faker::Lorem.sentence(word_count: 8)
        }

        # Configurar parámetros adicionales según el estado
        case status
        when 'in_storage'
          item_location_params[:section_id] = Section.all.sample.id
        when 'assigned'
          item_location_params[:return_date] = Faker::Date.between(from: Date.today, to: 3.months.from_now)
        end

        begin
          ItemLocation.create!(item_location_params)
        rescue => e
          puts "Error creating ItemLocation for Stock #{stock.id}: #{e.message}"
          puts item_location_params.inspect
        end
      end
    end
  end
end

puts "Seeding completed successfully!"