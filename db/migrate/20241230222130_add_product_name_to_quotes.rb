class AddProductNameToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :product_name, :string
  end
end
