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

    accepts_nested_attributes_for :quote_processes, allow_destroy: true
    accepts_nested_attributes_for :quote_extras, allow_destroy: true

    belongs_to :material, optional: true
    belongs_to :unit, optional: true
    belongs_to :manual_material_unit, class_name: 'Unit', optional: true

    before_save :set_default_values
    before_save :set_calculated_values

    def tax_amount
        (total_quote_value || 0) * 0.16
    end

    def total_with_tax
        (total_quote_value || 0) * 1.16
    end

    def calculate_products_per_sheet
        return 0 unless material && product_width && product_length

        # Calculate how many products fit in width and length
        products_in_width = (material.width / product_width).floor
        products_in_length = (material.length / product_length).floor

        # Total products per sheet is the multiplication
        products_in_width * products_in_length
    end

    def calculate_sheets_needed
        products_per_sheet = calculate_products_per_sheet
        return 0 if products_per_sheet == 0

        # Calculate sheets needed, rounding up
        (product_quantity.to_f / products_per_sheet).ceil
    end

    def calculate_material_square_meters
        return 0 unless amount_of_sheets && material
        
        width = material&.width || manual_material_width
        length = material&.length || manual_material_length
        
        (width * length * amount_of_sheets) / 10000.0  # Convert to square meters
    end

    private

    def set_default_values
        self.waste_price ||= 0
        self.margin_price ||= 0
        self.total_quote_value ||= 0
    end

    def set_calculated_values
        self.amount_of_sheets = calculate_sheets_needed
        self.products_per_sheet = calculate_products_per_sheet
        self.material_square_meters = calculate_material_square_meters
    end
end