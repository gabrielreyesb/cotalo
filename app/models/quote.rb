class Quote < ApplicationRecord
    validates :customer_email, presence: true
    validates :product_quantity, presence: true, numericality: { greater_than: 0 }
    validates :waste_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :margin_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    has_many :quote_processes, dependent: :destroy
    has_many :quote_toolings, dependent: :destroy
    has_many :manufacturing_processes, through: :quote_processes
    has_many :toolings, through: :quote_toolings

    accepts_nested_attributes_for :quote_processes, allow_destroy: true
    accepts_nested_attributes_for :quote_toolings, allow_destroy: true

    belongs_to :material, optional: true
    belongs_to :unit, optional: true
    belongs_to :manual_material_unit, class_name: 'Unit', optional: true

    before_save :set_default_prices

    private

    def set_default_prices
        self.waste_price ||= 0
        self.margin_price ||= 0
    end
end