class ManufacturingProcess < ApplicationRecord
  belongs_to :unit

  has_many :quote_processes
  has_many :quotes, through: :quote_processes
end
