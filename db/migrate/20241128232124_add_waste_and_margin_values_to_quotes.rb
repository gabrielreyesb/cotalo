class AddWasteAndMarginValuesToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :waste_price, :decimal, null: false
    add_column :quotes, :margin_price, :decimal, null: false
  end
end
