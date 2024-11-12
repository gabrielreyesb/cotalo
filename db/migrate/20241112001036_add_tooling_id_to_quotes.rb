class AddToolingIdToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_reference :quotes, :tooling, null: true, foreign_key: true, default: 1 
  end
end