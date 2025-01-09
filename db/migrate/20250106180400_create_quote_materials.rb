class CreateQuoteMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :quote_materials do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :material, null: false, foreign_key: true
      t.integer :products_per_sheet
      t.integer :sheets_needed
      t.decimal :square_meters
      t.decimal :total_price

      t.timestamps
    end
  end
end 