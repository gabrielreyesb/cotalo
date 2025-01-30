class AssociateExistingRecordsWithUser < ActiveRecord::Migration[7.1]
  def up
    user = User.first
    raise ActiveRecord::IrreversibleMigration, "Can't migrate without a user" unless user

    tables = {
      materials: 'materials',
      manufacturing_processes: 'manufacturing_processes',
      extras: 'extras',
      units: 'units',
      unit_equivalences: 'unit_equivalences',
      general_configurations: 'general_configurations',
      quotes: 'quotes'
    }

    # Add nullable user_id columns
    tables.each do |key, table|
      add_reference table.to_sym, :user, null: true, foreign_key: true
      
      # Count records before update
      count_before = execute("SELECT COUNT(*) FROM #{table}").first[0]
      puts "Table #{table} has #{count_before} records before update"
      
      # Update records
      execute("UPDATE #{table} SET user_id = #{user.id} WHERE user_id IS NULL")
      
      # Verify update
      count_null = execute("SELECT COUNT(*) FROM #{table} WHERE user_id IS NULL").first[0]
      if count_null > 0
        # If there are still null records, let's see their IDs
        null_records = execute("SELECT id FROM #{table} WHERE user_id IS NULL").to_a
        raise "Found #{count_null} records without user_id in #{table}. Record IDs: #{null_records.join(', ')}"
      end
      
      # Make column non-nullable
      change_column_null table.to_sym, :user_id, false
      puts "Successfully updated #{table}"
    end
  end

  def down
    tables = [
      :materials,
      :manufacturing_processes,
      :extras,
      :units,
      :unit_equivalences,
      :general_configurations,
      :quotes
    ]

    tables.each do |table|
      remove_reference table, :user
    end
  end
end
