class AddSubtotalBeforeMarginFieldToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :price_per_piece_before_margin, :decimal, precision: 10, scale: 2
  end
end 