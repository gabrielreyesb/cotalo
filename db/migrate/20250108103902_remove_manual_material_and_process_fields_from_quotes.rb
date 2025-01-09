class RemoveManualMaterialAndProcessFieldsFromQuotes < ActiveRecord::Migration[7.1]
  def change
    # Remove manual material fields
    remove_column :quotes, :manual_material, :string
    remove_column :quotes, :manual_material_unit_id, :integer
    remove_column :quotes, :manual_material_price, :decimal
    remove_column :quotes, :manual_material_width, :string
    remove_column :quotes, :manual_material_length, :string
    
    # Remove unnecessary process reference
    remove_column :quotes, :manufacturing_process_id, :integer
  end
end 