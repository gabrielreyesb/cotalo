class Unit < ApplicationRecord
  has_many :materials 
  has_many :general_configurations
end
