class RenameToolingsToExtras < ActiveRecord::Migration[7.1]
  def change
    rename_table :toolings, :extras
    rename_table :quote_toolings, :quote_extras
    rename_column :quote_extras, :tooling_id, :extra_id
  end
end 