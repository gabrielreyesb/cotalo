class RenameCustomerCompanyToCustomerOrganization < ActiveRecord::Migration[7.0]
  def change
    rename_column :quotes, :customer_company, :customer_organization 
  end
end