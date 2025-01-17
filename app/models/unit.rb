class Unit < ApplicationRecord
  has_many :materials, dependent: :destroy
  has_many :manufacturing_processes, dependent: :destroy
  has_many :extras, dependent: :destroy
end
