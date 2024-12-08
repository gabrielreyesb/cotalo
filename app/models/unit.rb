class Unit < ApplicationRecord
  has_many :materials 
  has_many :general_configurations
  has_many :quotes
  has_many :manufacturing_processes
end
