class AddCommentsToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_column :quotes, :comments, :text
  end
end