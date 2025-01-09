class QuoteMaterial < ApplicationRecord
  belongs_to :quote
  belongs_to :material

  validates :total_price, presence: true
  validates :material_id, presence: true
end 