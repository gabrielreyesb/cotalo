require "test_helper"

class QuoteCalculationTest < ActiveSupport::TestCase
  class TestQuote
    attr_accessor :product_quantity, :product_width, :product_length, :material

    def initialize(attributes = {})
      @product_quantity = attributes[:product_quantity]
      @product_width = attributes[:product_width]
      @product_length = attributes[:product_length]
      @material = attributes[:material]
    end

    def calculate_products_per_sheet
      return 0 unless material && product_width && product_length
      products_in_width = (material.width / product_width).floor
      products_in_length = (material.length / product_length).floor
      products_in_width * products_in_length
    end

    def calculate_sheets_needed
      products_per_sheet = calculate_products_per_sheet
      return 0 if products_per_sheet == 0
      (product_quantity.to_f / products_per_sheet).ceil
    end
  end

  def setup
    @material = OpenStruct.new(width: 100, length: 70)
    @quote = TestQuote.new(
      product_quantity: 1000,
      product_width: 30,
      product_length: 20,
      material: @material
    )
  end

  test "calculates correct number of products per sheet" do
    # For a 100x70 material and 30x20 product, we should fit 6 products (2x3)
    assert_equal 6, @quote.calculate_products_per_sheet
  end

  test "calculates correct number of sheets needed" do
    # For 1000 products with 6 products per sheet, we need 167 sheets (rounded up)
    assert_equal 167, @quote.calculate_sheets_needed
  end
end
