class RemoveUnusedTables < ActiveRecord::Migration[7.1]
  def up
    drop_table :customers
    drop_table :vendors
    drop_table :papers
  end

  def down
    create_table :customers do |t|
      t.string :name
      t.string :email
      t.string :contact
      t.timestamps
    end

    create_table :vendors do |t|
      t.string :company
      t.string :contact_name
      t.timestamps
    end

    create_table :papers do |t|
      t.string :description
      t.string :size
      t.string :weight
      t.timestamps
    end
  end
end
