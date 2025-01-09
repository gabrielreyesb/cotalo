class Quote < ApplicationRecord
    validates :customer_email, presence: true
    validates :product_quantity, presence: true, numericality: { greater_than: 0 }
    validates :waste_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :margin_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :total_quote_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    has_many :quote_processes, dependent: :destroy, class_name: 'QuoteProcess'
    has_many :quote_extras, dependent: :destroy
    has_many :manufacturing_processes, through: :quote_processes
    has_many :extras, through: :quote_extras
    has_many :quote_materials, dependent: :destroy
    has_many :materials, through: :quote_materials

    accepts_nested_attributes_for :quote_processes, allow_destroy: true
    accepts_nested_attributes_for :quote_extras, allow_destroy: true
    accepts_nested_attributes_for :quote_materials, allow_destroy: true

    belongs_to :material, optional: true
    belongs_to :unit, optional: true
    belongs_to :manual_material_unit, class_name: 'Unit', optional: true
end