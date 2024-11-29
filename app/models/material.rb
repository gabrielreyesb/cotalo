class Material < ApplicationRecord
    belongs_to :unit 
    has_many :quotes
end