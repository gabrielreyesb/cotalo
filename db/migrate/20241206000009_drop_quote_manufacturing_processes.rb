class DropQuoteManufacturingProcesses < ActiveRecord::Migration[7.1]
  def up
    drop_table :quote_manufacturing_processes
  end
end
