class AddCommentsToQuoteProcesses < ActiveRecord::Migration[7.1]
  def change
    add_column :quote_processes, :comments, :text
  end
end
