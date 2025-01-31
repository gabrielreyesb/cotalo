class AssociateExistingRecordsWithUser < ActiveRecord::Migration[7.0]
  def up
    # First add user_id columns to all necessary tables
    tables = %w[
      materials
      manufacturing_processes
      extras
      units
      unit_equivalences
      general_configurations
      quotes
    ]

    tables.each do |table|
      unless column_exists?(table, :user_id)
        add_reference table, :user, null: true, foreign_key: true
      end
    end

    # Now create/get user and associate records
    if User.count == 0
      user = User.create!(
        email: 'admin@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    else
      user = User.first
    end

    # Update all records to belong to the user
    tables.each do |table|
      execute("UPDATE #{table} SET user_id = #{user.id} WHERE user_id IS NULL")
      change_column_null table.to_sym, :user_id, false
    end
  end

  def down
    tables = %w[
      materials
      manufacturing_processes
      extras
      units
      unit_equivalences
      general_configurations
      quotes
    ]

    tables.each do |table|
      remove_reference table, :user, foreign_key: true if column_exists?(table, :user_id)
    end
  end
end
