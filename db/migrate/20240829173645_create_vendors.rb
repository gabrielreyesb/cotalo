class CreateVendors < ActiveRecord::Migration[7.1]
  def change
    create_table :vendors do |t|
      t.string :company
      t.string :contact_name

      t.timestamps
    end
  end
end
