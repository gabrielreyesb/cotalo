class AdjustMaterialsTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :materials, :height, :decimal 
    remove_column :materials, :weight, :decimal

    add_column :materials, :price, :decimal, precision: 10, scale: 2
    add_reference :materials, :unit, null: false, foreign_key: true 
  end
end