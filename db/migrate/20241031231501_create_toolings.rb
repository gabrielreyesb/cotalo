class CreateToolings < ActiveRecord::Migration[7.0]
  def change
    create_table :toolings do |t|
      t.string :description
      t.decimal :price, precision: 10, scale: 2
      t.references :unit, null: false, foreign_key: true

      t.timestamps
    end
  end
end