class NewCreateQuoteToolings < ActiveRecord::Migration[6.0]
  def change
    unless table_exists?(:quote_toolings)
      create_table :quote_toolings do |t|
        t.references :quote, null: false, foreign_key: true
        t.references :tooling, null: false, foreign_key: true
        t.decimal :price, null: false
        t.integer :quantity, null: false

        t.timestamps
      end
    end
  end
end