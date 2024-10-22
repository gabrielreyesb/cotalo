class CreateMaterials < ActiveRecord::Migration[7.1]
  def change
    create_table :materials do |t|
      t.string :description
      t.decimal :weight
      t.decimal :width
      t.decimal :height
      t.decimal :lenght
      t.string :comments

      t.timestamps
    end
  end
end
