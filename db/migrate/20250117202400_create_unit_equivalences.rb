class CreateUnitEquivalences < ActiveRecord::Migration[7.1]
    def change
      create_table :unit_equivalences do |t|
        t.references :unit_one, null: false, foreign_key: { to_table: :units }
        t.references :unit_two, null: false, foreign_key: { to_table: :units }
        t.decimal :conversion_factor, precision: 15, scale: 6, null: false
  
        t.timestamps
      end
      
      add_index :unit_equivalences, [:unit_one_id, :unit_two_id], unique: true
    end
  end