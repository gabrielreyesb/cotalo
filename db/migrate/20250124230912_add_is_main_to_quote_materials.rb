class AddIsMainToQuoteMaterials < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_materials, :is_main, :boolean, default: false, null: false
  end
end
