class UpdateUnitEquivalencesTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :unit_equivalences, :unit_one, :string
    remove_column :unit_equivalences, :unit_two, :string
    add_reference :unit_equivalences, :unit_one, foreign_key: { to_table: :units }
    add_reference :unit_equivalences, :unit_two, foreign_key: { to_table: :units }
  end
end 