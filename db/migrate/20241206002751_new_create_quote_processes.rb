class NewCreateQuoteProcesses < ActiveRecord::Migration[7.1]
  def change
    create_table :quote_processes do |t|
      t.references :quote, null: false, foreign_key: true
      t.references :manufacturing_process, null: false, foreign_key: true
      t.decimal :price, null: false

      t.timestamps
    end
  end
end
