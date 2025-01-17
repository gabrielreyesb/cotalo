class Extra < ApplicationRecord
  belongs_to :unit
  validates :unit, presence: true
end 