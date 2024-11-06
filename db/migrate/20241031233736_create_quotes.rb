class CreateQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :quotes do |t|
      t.decimal :width
      t.decimal :length
      t.integer :pieces
      t.references :material, null: false, foreign_key: true

      t.timestamps
    end
  end
end
