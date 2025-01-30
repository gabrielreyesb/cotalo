class AddUnitPriceToQuoteProcesses < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_processes, :unit_price, :decimal
  end
end
