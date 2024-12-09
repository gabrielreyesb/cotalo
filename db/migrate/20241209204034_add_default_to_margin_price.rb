class AddDefaultToMarginPrice < ActiveRecord::Migration[7.0]
  def change
    change_column_default :quotes, :margin_price, 0
    change_column_null :quotes, :margin_price, true
  end
end