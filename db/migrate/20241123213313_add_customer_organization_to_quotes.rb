class AddCustomerOrganizationToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :customer_organization, :string
  end
end
