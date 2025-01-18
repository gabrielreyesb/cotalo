class FixUnitEquivalencesColumns < ActiveRecord::Migration[7.1]
  def change
    # First make the reference columns non-nullable
    change_column_null :unit_equivalences, :unit_one_id, false
    change_column_null :unit_equivalences, :unit_two_id, false

    # Remove the old string columns
    remove_column :unit_equivalences, :unit_one, :string
    remove_column :unit_equivalences, :unit_two, :string

    # Remove old index if it exists
    remove_index :unit_equivalences, [:unit_one, :unit_two], if_exists: true

    # Add new unique index on the ID columns
    add_index :unit_equivalences, [:unit_one_id, :unit_two_id], unique: true, name: 'index_unit_equivalences_on_unit_one_id_and_unit_two_id'
  end
end 