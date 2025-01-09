class AddManualFieldsToQuoteMaterials < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_materials, :is_manual, :boolean, default: false
    add_column :quote_materials, :manual_description, :string
    add_column :quote_materials, :manual_unit, :string
    change_column_null :quote_materials, :material_id, true
  end
end 