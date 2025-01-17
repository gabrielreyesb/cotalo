# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data in the correct order
puts "Clearing existing data..."
QuoteMaterial.destroy_all
QuoteProcess.destroy_all
QuoteExtra.destroy_all
Quote.destroy_all
Material.destroy_all
ManufacturingProcess.destroy_all
Extra.destroy_all
GeneralConfiguration.destroy_all
Unit.destroy_all

# Create Units
puts "Creating units..."
units = [
  { description: '%' },
  { description: 'aplicación' },
  { description: 'pieza' },
  { description: 'cms' },
  { description: 'mt2' },
  { description: 'pliego' }
]

units.each do |unit|
  Unit.create!(unit)
end

# Create Materials
puts "Creating materials..."
materials = [
  { 
    description: 'Pleca 70x50', 
    unit: Unit.find_by(description: 'mt2'),
    width: 70,
    length: 50,
    price: 2.20,
    comments: 'Datos para pruebas'  
  },
  { 
    description: 'Pleca 90x70', 
    unit: Unit.find_by(description: 'mt2'),
    width: 90,
    length: 70,
    price: 2.75,
    comments: 'Datos para pruebas'
  }
]

materials.each do |material|
  Material.create!(material)
end

# Create Manufacturing Processes
puts "Creating manufacturing processes..."
processes = [
  {
    name: 'BARNIZ ACRILICO 4 OFICIOS',
    description: 'BARNIZ ACRILICO 4 OFICIOS',
    unit: Unit.find_by(description: 'pieza'),
    price: 0.50,
    maximum_length: 71,
    maximum_width: 53,
    minimum_length: 40,
    minimum_width: 30
  },
  {
    name: 'Impresión 4 oficios',
    description: 'Impresión 4 oficios',
    unit: Unit.find_by(description: 'mt2'),
    price: 10.00,
    maximum_length: 85,
    maximum_width: 65,
    minimum_length: 20,
    minimum_width: 10
  }
]

processes.each do |process|
  ManufacturingProcess.create!(process)
end

# Create Extras
puts "Creating extras..."
extras = [
  {
    description: 'MADERA PARA SUAJE',
    unit: Unit.find_by(description: 'cms'),
    price: 0.12
  }
]

extras.each do |extra|
  Extra.create!(extra)
end

# Create General Configurations
puts "Creating general configurations..."
configs = [
  {
    description: 'margen',
    amount: '25',
    unit: Unit.find_by(description: '%')
  },
  {
    description: 'merma',
    amount: '5',
    unit: Unit.find_by(description: '%')
  },
  {
    description: 'Margen ancho',
    amount: '2',
    unit: Unit.find_by(description: 'cms')
  },
  {
    description: 'Margen largo',
    amount: '2',
    unit: Unit.find_by(description: 'cms')
  }
]

configs.each do |config|
  GeneralConfiguration.create!(config)
end

puts "Seed completed successfully!"
