class AddDimensionsToQuoteMaterials < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_materials, :manual_width, :decimal, precision: 10, scale: 2
    add_column :quote_materials, :manual_length, :decimal, precision: 10, scale: 2
  end
end 