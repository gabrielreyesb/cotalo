class AddDefaultToWastePrice < ActiveRecord::Migration[7.0]
  def change
    change_column_default :quotes, :waste_price, 0
    change_column_null :quotes, :waste_price, true
  end
end