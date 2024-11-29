class CreateQuotesNew < ActiveRecord::Migration[7.0]  # Adjust the version number as necessary
  def change
    create_table :quotes do |t|
      t.string :projects_name, null: false  # Project name, required
      t.string :customer_name, null: false  # Customer's name, required
      t.string :customer_company, null: false  # Customer's company, required
      t.string :customer_email  # Customer's email, optional
      t.integer :product_pieces, null: false  # Product pieces, required
      t.decimal :product_width, null: false  # Product width, required
      t.decimal :product_length, null: false  # Product length, required
      t.integer :material_id  # Material ID, optional
      t.integer :material_unit_id  # Material Unit ID, optional
      t.decimal :material_price  # Material price, optional
      t.string :manual_material  # Manual material, optional
      t.decimal :manual_material_width  # Manual material width, optional
      t.decimal :manual_material_length  # Manual material length, optional
      t.integer :products_per_sheet, null: false  # Products per sheet, required
      t.integer :sheets_needed, null: false  # Sheets needed, required
      t.decimal :material_total_price, null: false  # Material price, required
      t.decimal :material_square_meters, null: false  # Material square meters, required
      t.decimal :subtotal, null: false  # Subtotal, required
      t.decimal :waste, null: false  # Waste, required
      t.decimal :margin, null: false  # Margin, required
      t.decimal :total_price, null: false  # Total price, required
      t.decimal :price_per_piece, null: false  # Price per piece, required

      t.timestamps  # This will add created_at and updated_at fields
    end
  end
end