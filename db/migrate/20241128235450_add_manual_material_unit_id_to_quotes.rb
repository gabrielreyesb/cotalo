class AddManualMaterialUnitIdToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :manual_material_unit_id, :integer
  end
end
