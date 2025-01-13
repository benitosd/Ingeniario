require 'faker'

# Limpiar datos existentes
puts "Cleaning database..."
Item.destroy_all
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

# Crear ítems dentro de cada grupo usando las propiedades del grupo
puts "Creating items..."
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
  end
end

puts "Seeding completed successfully!"
