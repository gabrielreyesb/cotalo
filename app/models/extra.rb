class Extra < ApplicationRecord
  belongs_to :unit
  has_many :quote_extras, dependent: :destroy
  has_many :quotes, through: :quote_extras
  
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end 