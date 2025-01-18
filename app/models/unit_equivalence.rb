class UnitEquivalence < ApplicationRecord
  belongs_to :unit_one, class_name: 'Unit'
  belongs_to :unit_two, class_name: 'Unit'

  validates :conversion_factor, presence: true, numericality: { greater_than: 0 }
  validates :unit_one_id, presence: true
  validates :unit_two_id, presence: true
  validates :unit_one_id, uniqueness: { scope: :unit_two_id, message: "ya existe una equivalencia para estas unidades" }
end
