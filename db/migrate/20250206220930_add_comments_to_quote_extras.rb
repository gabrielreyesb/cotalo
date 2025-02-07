class AddCommentsToQuoteExtras < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_extras, :comments, :text
  end
end
