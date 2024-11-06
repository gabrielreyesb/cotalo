class AddFieldsToManufacturingProcesses < ActiveRecord::Migration[7.1]
  def change
    add_column :manufacturing_processes, :name, :string
    add_column :manufacturing_processes, :specifications, :string
    add_column :manufacturing_processes, :comments, :string
  end
end
