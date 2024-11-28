class AddManualManufacrturingProcessIdToQuotes < ActiveRecord::Migration[7.1]
  def change
    add_column :quotes, :manufacturing_process_id, :integer
  end
end
