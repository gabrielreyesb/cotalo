class AddCommentsToQuoteMaterials < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_materials, :comments, :text
  end
end
