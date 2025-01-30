class AddDimensionsAndPriceToQuoteMaterials < ActiveRecord::Migration[7.0]
  def change
    add_column :quote_materials, :price_per_unit, :decimal, precision: 10, scale: 2
    add_column :quote_materials, :width, :decimal, precision: 10, scale: 2
    add_column :quote_materials, :length, :decimal, precision: 10, scale: 2
  end
end
