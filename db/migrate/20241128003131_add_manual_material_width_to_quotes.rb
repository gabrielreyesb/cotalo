class AddManualMaterialWidthToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :manual_material_width, :string
  end
end
