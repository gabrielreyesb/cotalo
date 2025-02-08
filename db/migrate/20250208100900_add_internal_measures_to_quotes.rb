class AddInternalMeasuresToQuotes < ActiveRecord::Migration[7.0]
  def change
    add_column :quotes, :internal_measures, :string
  end
end 