class CreateQuoteToolings < ActiveRecord::Migration[7.1]
  def change
    create_table :quote_toolings do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :tooling, null: false, foreign_key: true

      t.timestamps
    end
  end
end
