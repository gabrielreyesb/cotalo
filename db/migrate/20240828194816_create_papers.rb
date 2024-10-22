class CreatePapers < ActiveRecord::Migration[7.1]
  def change
    create_table :papers do |t|
      t.string :description
      t.string :size
      t.decimal :weight

      t.timestamps
    end
  end
end
