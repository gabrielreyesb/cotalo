class AddIncludeExtrasToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :include_extras, :boolean, default: false
  end
end