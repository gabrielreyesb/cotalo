class FixQuoteMaterialsForeignKey < ActiveRecord::Migration[7.1]
  def change
    # Remove the existing foreign key
    remove_foreign_key :quote_materials, :materials
    
    # Add the foreign key back with nullify on delete
    add_foreign_key :quote_materials, :materials, on_delete: :nullify
  end
end
