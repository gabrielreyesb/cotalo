class CreateAppSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :app_settings do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :key, null: false
      t.text :value
      t.string :value_type, default: 'string'  # string, number, array, json
      t.string :category    # 'financial', 'pdf', etc.
      t.string :description
      
      t.timestamps
      t.index [:user_id, :key], unique: true
    end
  end
end 