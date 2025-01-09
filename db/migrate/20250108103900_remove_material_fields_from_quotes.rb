class RemoveMaterialFieldsFromQuotes < ActiveRecord::Migration[7.1]
  def change
    remove_column :quotes, :products_per_sheet, :integer
    remove_column :quotes, :amount_of_sheets, :integer
    remove_column :quotes, :material_total_price, :decimal
    remove_column :quotes, :material_square_meters, :decimal
  end
end 