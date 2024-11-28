class AddManualMaterialToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_column :quotes, :manual_material, :string
    add_column :quotes, :manual_material_unit_id, :integer, foreign_key: { to_table: :units }
    add_column :quotes, :manual_material_price, :decimal
  end
end