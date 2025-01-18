class Extra < ApplicationRecord
  belongs_to :unit
  validates :unit, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end 