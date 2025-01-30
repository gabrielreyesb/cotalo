class GeneralConfiguration < ApplicationRecord
    belongs_to :unit, optional: true
    belongs_to :user
    
    default_scope { order(Arel.sql("LOWER(description) ASC")) }

    validates :description, presence: true
    validates :amount, presence: true
    validates :user, presence: true

    # Scope to find configurations belonging to a specific user
    scope :for_user, ->(user) { where(user: user) }
end
