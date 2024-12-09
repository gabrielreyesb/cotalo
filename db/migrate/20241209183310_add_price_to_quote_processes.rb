class AddPriceToQuoteProcesses < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_processes, :price, :decimal
  end
end
