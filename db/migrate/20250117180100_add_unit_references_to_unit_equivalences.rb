class AddUnitReferencesToUnitEquivalences < ActiveRecord::Migration[7.1]
  def change
    add_reference :unit_equivalences, :unit_one, foreign_key: { to_table: :units }
    add_reference :unit_equivalences, :unit_two, foreign_key: { to_table: :units }
  end
end 