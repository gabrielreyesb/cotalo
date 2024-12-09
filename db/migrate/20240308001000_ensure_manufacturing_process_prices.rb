class EnsureManufacturingProcessPrices < ActiveRecord::Migration[7.0]
  def up
    # First ensure the price column exists with proper constraints
    unless column_exists?(:manufacturing_processes, :price)
      add_column :manufacturing_processes, :price, :decimal, precision: 10, scale: 2, default: 0
    end
    
    # Update any existing records that have nil prices
    execute <<-SQL
      UPDATE manufacturing_processes 
      SET price = 0 
      WHERE price IS NULL OR price = 0
    SQL
    
    # Add the not null constraint after ensuring no null values exist
    change_column_null :manufacturing_processes, :price, false
  end

  def down
    change_column_null :manufacturing_processes, :price, true
  end
end 