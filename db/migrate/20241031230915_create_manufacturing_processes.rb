class CreateManufacturingProcesses < ActiveRecord::Migration[7.1]
  def change
    create_table :manufacturing_processes do |t|
      t.string :description
      t.decimal :price
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
