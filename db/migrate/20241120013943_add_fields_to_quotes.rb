class AddFieldsToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :projects_name, :string
    add_column :quotes, :sub_total_value, :decimal
    add_column :quotes, :waste_value, :decimal
    add_column :quotes, :margin_value, :decimal
    add_column :quotes, :total_value, :decimal
    add_column :quotes, :value_per_piece, :decimal
  end
end
