class RenameLenghtToLengthInMaterials < ActiveRecord::Migration[6.0]
  def change
    rename_column :materials, :lenght, :length
  end
end