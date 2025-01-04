class QuoteExtra < ApplicationRecord
  belongs_to :quote
  belongs_to :extra

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end 