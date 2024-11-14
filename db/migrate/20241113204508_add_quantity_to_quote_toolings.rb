class AddQuantityToQuoteToolings < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_toolings, :quantity, :integer
  end
end
