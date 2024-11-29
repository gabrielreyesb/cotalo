class DropQuotesTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :quotes
  end
end
