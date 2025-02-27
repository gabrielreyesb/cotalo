class CreatePdfCounters < ActiveRecord::Migration[7.1]
  def change
    create_table :pdf_counters do |t|
      t.integer :current_number, default: 0, null: false

      t.timestamps
    end

    # Create the initial counter record
    reversible do |dir|
      dir.up do
        PdfCounter.create!(current_number: 0)
      end
    end
  end
end
