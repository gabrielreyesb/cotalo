class QuoteProcess < ApplicationRecord
  belongs_to :quote
  belongs_to :manufacturing_process
  
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Add price to attr_accessible if you're using it
  attr_accessible :manufacturing_process_id, :price if defined?(attr_accessible)
end
