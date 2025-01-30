class Unit < ApplicationRecord
  belongs_to :user
  has_many :materials, dependent: :restrict_with_error
  has_many :manufacturing_processes, dependent: :restrict_with_error
  has_many :extras, dependent: :restrict_with_error

  validates :description, presence: true
  validates :user, presence: true

  # Scope to find units belonging to a specific user
  scope :for_user, ->(user) { where(user: user) }
end
