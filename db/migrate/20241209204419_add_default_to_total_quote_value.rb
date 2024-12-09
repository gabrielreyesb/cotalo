class AddDefaultToTotalQuoteValue < ActiveRecord::Migration[7.0]
  def change
    change_column_default :quotes, :total_quote_value, from: nil, to: 0
  end
end