require "minitest/autorun"
require "ostruct"

class QuoteCalculationTest < Minitest::Test
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

    def calculate_material_price
      sheets_needed = calculate_sheets_needed
      return 0 if sheets_needed == 0
      sheets_needed * material.price
    end

    def calculate_material_square_meters
      sheets_needed = calculate_sheets_needed
      return 0 if sheets_needed == 0
      (material.length * material.width * sheets_needed) / 10000
    end
end

  def setup
    @material = OpenStruct.new(
      width: 90, 
      length: 70,
      price: 2.43
    )
    @quote = TestQuote.new(
      product_quantity: 2000,
      product_width: 36,
      product_length: 25,
      material: @material
    )
  end

  def test_calculates_correct_number_of_products_per_sheet
    # For a 90x70 material and 36x25 product:
    # Width: floor(90/36) = 2 products
    # Length: floor(70/25) = 2 products
    # Total: 2 × 2 = 4 products per sheet
    assert_equal 4, @quote.calculate_products_per_sheet
  end

  def test_calculates_correct_number_of_sheets_needed
    # For 2000 products with 4 products per sheet:
    # 2000/4 = 500 sheets
    assert_equal 500, @quote.calculate_sheets_needed
  end

  def test_calculates_correct_material_price
    # For a price of 2.43 per sheet:
    # 500 sheets * 2.43 = 1215
    assert_equal 1215, @quote.calculate_material_price
  end

  def test_calculates_correct_square_meters
    # For a 90x70 material:
    # 90 * 70 * 500 / 10000 = 315 square meters
    assert_equal 315, @quote.calculate_material_square_meters
  end
end 
