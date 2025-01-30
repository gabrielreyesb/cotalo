class AddPrecisionToQuoteProcessPrices < ActiveRecord::Migration[7.1]
  def change
    change_column :quote_processes, :price, :decimal, precision: 10, scale: 2
    change_column :quote_processes, :unit_price, :decimal, precision: 10, scale: 2
  end
end 