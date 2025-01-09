class RemoveAdditionalMaterialFieldsFromQuotes < ActiveRecord::Migration[7.1]
  def change
    remove_column :quotes, :pieces, :integer
    remove_column :quotes, :material_id, :integer
    remove_column :quotes, :material_unit_id, :integer
    remove_column :quotes, :material_price, :decimal
  end
end 