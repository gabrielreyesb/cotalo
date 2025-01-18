class CreateUnitEquivalences < ActiveRecord::Migration[7.0]
  def change
    create_table :unit_equivalences do |t|
      t.string :unit_one, null: false
      t.string :unit_two, null: false
      t.decimal :conversion_factor, precision: 15, scale: 6, null: false

      t.timestamps
    end
    
    # Add an index to make lookups faster
    add_index :unit_equivalences, [:unit_one, :unit_two], unique: true
  end
end