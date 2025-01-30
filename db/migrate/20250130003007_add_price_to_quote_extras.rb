class AddPriceToQuoteExtras < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_extras, :price, :decimal, precision: 10, scale: 2
  end
end
