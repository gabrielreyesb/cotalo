class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :contact
      t.string :email

      t.timestamps
    end
  end
end
