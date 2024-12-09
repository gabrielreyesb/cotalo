class UpdateQuoteTotalDefaultValue < ActiveRecord::Migration[7.0]
  def up
    # First set existing nil values to 0
    Quote.where(total_quote_value: nil).update_all(total_quote_value: 0)
    
    # Then change the default
    change_column_default :quotes, :total_quote_value, 0
  end

  def down
    change_column_default :quotes, :total_quote_value, nil
  end
end