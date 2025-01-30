class RemoveAndRecreateQuoteMaterialsForeignKey < ActiveRecord::Migration[7.1]
  def up
    # Remove existing constraints
    remove_foreign_key :quote_materials, :materials rescue nil
    remove_index :quote_materials, :material_id rescue nil
    
    # Make material_id nullable
    change_column_null :quote_materials, :material_id, true
    
    # Add back the index
    add_index :quote_materials, :material_id
    
    # Add the foreign key with nullify on delete
    add_foreign_key :quote_materials, :materials, on_delete: :nullify
  end

  def down
    remove_foreign_key :quote_materials, :materials rescue nil
    remove_index :quote_materials, :material_id rescue nil
    
    # Restore original state
    change_column_null :quote_materials, :material_id, false
    add_index :quote_materials, :material_id
    add_foreign_key :quote_materials, :materials
  end
end
