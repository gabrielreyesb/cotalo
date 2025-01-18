class UpdateUnitEquivalencesTable < ActiveRecord::Migration[7.1]
  def change
    remove_column :unit_equivalences, :unit_one, :string
    remove_column :unit_equivalences, :unit_two, :string
  end
end 