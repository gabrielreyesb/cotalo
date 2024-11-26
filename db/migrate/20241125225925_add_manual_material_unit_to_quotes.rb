class AddManualMaterialUnitToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_column :quotes, :manual_material_unit, :integer
  end
end