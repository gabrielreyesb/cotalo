class AddCustomerPhoneToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :customer_phone, :string
  end
end
