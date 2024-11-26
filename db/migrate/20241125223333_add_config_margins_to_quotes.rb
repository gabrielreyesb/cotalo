class AddConfigMarginsToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_column :quotes, :config_margin_width, :decimal
    add_column :quotes, :config_margin_length, :decimal
  end
end