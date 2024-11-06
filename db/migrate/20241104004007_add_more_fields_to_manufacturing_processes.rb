class AddMoreFieldsToManufacturingProcesses < ActiveRecord::Migration[7.1]
  def change
    add_column :manufacturing_processes, :maximum, :integer
    add_column :manufacturing_processes, :minimum, :integer
  end
end
