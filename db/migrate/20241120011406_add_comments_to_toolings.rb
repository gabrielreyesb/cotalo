class AddCommentsToToolings < ActiveRecord::Migration[7.1]
  def change
    add_column :toolings, :comments, :text
  end
end
