class CreateQuoteManufacturingProcesses < ActiveRecord::Migration[6.0]
  def change
    create_table :quote_manufacturing_processes do |t|
      t.string :name
      t.string :description
      t.decimal :price
      t.string :unit
      t.references :quote, null: false, foreign_key: true

      t.timestamps
    end
  end
end