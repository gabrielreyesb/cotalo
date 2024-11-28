class AddManualMaterialLengthToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :manual_material_length, :string
  end
end
