class AddPricePerPieceBeforeMarginToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :price_per_piece_before_margin, :decimal
  end
end
