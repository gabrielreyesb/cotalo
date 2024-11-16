class AddCustomerNameToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :customer_name, :string
  end
end
