class DropPapersProcessesAndQuoteProcesses < ActiveRecord::Migration[7.1]
  def up
    drop_table :papers
    drop_table :processes
    drop_table :quote_processes
  end
end
