class AddManualMaterialUnitIdToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :quotes, :units, column: :manual_material_unit_id
  end
end