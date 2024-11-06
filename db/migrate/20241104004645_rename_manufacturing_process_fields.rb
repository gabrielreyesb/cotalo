class RenameManufacturingProcessFields < ActiveRecord::Migration[7.0]
  def change
    rename_column :manufacturing_processes, :maximum, :maximum_length
    rename_column :manufacturing_processes, :minimum, :maximum_width
  end
end