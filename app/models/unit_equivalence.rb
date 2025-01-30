class UnitEquivalence < ApplicationRecord
  belongs_to :unit_one, class_name: 'Unit'
  belongs_to :unit_two, class_name: 'Unit'
  belongs_to :user

  validates :conversion_factor, presence: true, numericality: { greater_than: 0 }
  validates :unit_one_id, presence: true
  validates :unit_two_id, presence: true
  validates :user, presence: true
  validates :unit_one_id, uniqueness: { 
    scope: [:unit_two_id, :user_id], 
    message: "ya existe una equivalencia para estas unidades" 
  }

  # Scope to find equivalences belonging to a specific user
  scope :for_user, ->(user) { where(user: user) }
end
