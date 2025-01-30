class AllowNullMaterialInQuoteMaterials < ActiveRecord::Migration[7.1]
  def up
    # Remove the existing foreign key
    remove_foreign_key :quote_materials, :materials
    
    # Change the column to allow null values
    change_column_null :quote_materials, :material_id, true
    
    # Add back the foreign key with null option
    add_foreign_key :quote_materials, :materials, on_delete: :restrict, null: true
  end

  def down
    # Remove the nullable foreign key
    remove_foreign_key :quote_materials, :materials
    
    # Change the column back to not null
    change_column_null :quote_materials, :material_id, false
    
    # Add back the strict foreign key
    add_foreign_key :quote_materials, :materials, on_delete: :restrict
  end
end
