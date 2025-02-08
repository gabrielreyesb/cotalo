class AddSpecificationsAndNameToMaterials < ActiveRecord::Migration[7.0]
  def change
    add_column :materials, :specifications, :string
    add_column :materials, :name, :string
  end
end 