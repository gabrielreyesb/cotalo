class Material < ApplicationRecord
    belongs_to :unit 
    belongs_to :user
    has_many :quote_materials, dependent: :destroy
    has_many :quotes, through: :quote_materials

    validates :description, presence: true
    validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :unit, presence: true
    validates :user, presence: true

    # Scope to find materials belonging to a specific user
    scope :for_user, ->(user) { where(user: user) }
end