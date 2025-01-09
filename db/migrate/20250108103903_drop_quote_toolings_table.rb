class DropQuoteToolingsTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :quote_toolings if table_exists?(:quote_toolings)
  end

  def down
    create_table :quote_toolings do |t|
      t.references :quote, foreign_key: true
      t.references :tooling, foreign_key: true
      t.timestamps
    end
  end
end 