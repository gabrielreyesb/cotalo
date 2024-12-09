class AddDefaultToTotalQuoteValue < ActiveRecord::Migration[7.0]
  def change
    change_column_default :quotes, :total_quote_value, 0
    change_column_null :quotes, :total_quote_value, true
  end
end