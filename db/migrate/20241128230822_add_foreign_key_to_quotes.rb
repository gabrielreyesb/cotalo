class AddForeignKeyToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :quotes, :materials, column: :material_id
    add_foreign_key :quotes, :units, column: :material_unit_id
  end
end
