# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
units = [
  { name: "M2", description: "Metros Cuadrados" },
  { name: "ML", description: "Metros Lineales" },
  { name: "Ud", description: "Unidades" }
]


units.each do |attributes|
  Unit.find_or_create_by(name: attributes[:name]) do |unit|
    unit.description = attributes[:description]
  end
end

families = [
  { name: "1000. CHAPA PERFILADA", description: "1000. CHAPA PERFILADA" },
  { name: "2000. CHAPA LISA", description: "2000. CHAPA LISA" },
  { name: "3000. PANELES", description: "3000. PANELES" },
  { name: "4000. FORJADO COLABORANTE", description: "4000. FORJADO COLABORANTE" },
  { name: "5000. REMATES", description: "5000. REMATES" },
  { name: "6000. TRASLUCIDOS", description: "6000. TRASLUCIDOS" },
  { name: "7000. TORNILLERIA", description: "7000. TORNILLERIA" },
  { name: "8000. VARIOS   (OMEGAS,MANTA,CUADRADILLO,JUNTA EST. SILICONA)", description: "8000. VARIOS   (OMEGAS,MANTA,CUADRADILLO,JUNTA EST. SILICONA)" },
  { name: "9000. FACHADAS   (OBRAS)", description: "9000.FACHADAS   (OBRAS)" },
  { name: "10000. CUBIERTAS   (OBRAS)", description: "10000.CUBIERTAS   (OBRAS)" },
  { name: "11000. CANALON Y AIREADORES", description: "11000.CANALON Y AIREADORES" },
  { name: "12000. SERVICIOS/ HORAS ADMINISTRACION", description: "12000. SERVICIOS/ HORAS ADMINISTRACION" },
  { name: "13000. DESMONTAJE", description: "13000.DESMONTAJE" },
  { name: "14000. REMATES CHAPA GALVANIZADA", description: "14000.REMATES CHAPA GALVANIZADA" },
  { name: "20000. REMATES TEJA", description: "20000. REMATES TEJA" },
  { name: "21000. CUADRADILLO", description: "21000. CUADRADILLO" },
  { name: "22000. OMEGAS", description: "22000. OMEGAS" },
  { name: "23000. FORJADO", description: "23000. FORJADO" },
  { name: "25000. PLETINAS", description: "25000. PLETINAS" },
  { name: "26000. TORNILLERIA", description: "26000. TORNILLERIA" }
]

families.each do |attributes|
  Family.find_or_create_by(name: attributes[:name]) do |family|
    family.description = attributes[:description]
  end
end