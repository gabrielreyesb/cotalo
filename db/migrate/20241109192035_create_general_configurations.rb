class CreateGeneralConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :general_configurations do |t|
      t.string :description
      t.decimal :amount

      t.timestamps
    end
  end
end
