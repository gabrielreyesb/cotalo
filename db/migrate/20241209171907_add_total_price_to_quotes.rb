class AddTotalPriceToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :total_price, :decimal
  end
end
