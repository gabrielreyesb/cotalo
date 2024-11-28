class UpdateQuotesTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :quotes, :width
    remove_column :quotes, :length
    remove_column :quotes, :material_id
    remove_column :quotes, :manufacturing_process_id
    remove_column :quotes, :tooling_id
    remove_column :quotes, :sub_total_value
    remove_column :quotes, :waste_value
    remove_column :quotes, :margin_value
    remove_column :quotes, :total_value
    remove_column :quotes, :value_per_piece
    remove_column :quotes, :config_margin_width
    remove_column :quotes, :config_margin_length
    remove_column :quotes, :manual_material_unit

    add_column :quotes, :customer_email, :string
    add_column :quotes, :product_quantity, :integer
    add_column :quotes, :product_width, :decimal
    add_column :quotes, :product_length, :decimal
    add_column :quotes, :material_id, :integer
    add_column :quotes, :material_unit_id, :integer
    add_column :quotes, :material_price, :decimal
    add_column :quotes, :products_per_sheet, :integer
    add_column :quotes, :amount_of_sheets, :integer
    add_column :quotes, :material_total_price, :decimal
    add_column :quotes, :material_square_meters, :decimal
    add_column :quotes, :subtotal, :decimal
    add_column :quotes, :waste_percentage, :decimal
    add_column :quotes, :margin_percentage, :decimal
    add_column :quotes, :total_quote_value, :decimal
    add_column :quotes, :product_value_per_piece, :decimal
  end
end