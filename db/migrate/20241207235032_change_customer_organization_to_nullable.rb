class ChangeCustomerOrganizationToNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :quotes, :customer_organization, true
  end
end