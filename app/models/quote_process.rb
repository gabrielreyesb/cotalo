class QuoteProcess < ApplicationRecord
  belongs_to :quote
  belongs_to :manufacturing_process
end
