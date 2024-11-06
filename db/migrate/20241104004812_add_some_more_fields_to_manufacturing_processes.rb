class AddSomeMoreFieldsToManufacturingProcesses < ActiveRecord::Migration[7.1]
  def change
    add_column :manufacturing_processes, :minimum_length, :integer
    add_column :manufacturing_processes, :minimum_width, :integer
  end
end
