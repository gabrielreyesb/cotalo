class AddPriceToQuoteProcesses < ActiveRecord::Migration[7.0]
  def change
    add_column :quote_processes, :price, :decimal, precision: 10, scale: 2
  end
end 