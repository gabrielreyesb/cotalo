class Extra < ApplicationRecord
  belongs_to :unit
  belongs_to :user
  has_many :quote_extras, dependent: :destroy
  has_many :quotes, through: :quote_extras
  
  validates :unit, presence: true
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user, presence: true

  # Scope to find extras belonging to a specific user
  scope :for_user, ->(user) { where(user: user) }
end 