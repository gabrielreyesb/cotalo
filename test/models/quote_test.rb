require "test_helper"

class QuoteTest < ActiveSupport::TestCase
  test "should not save quote without required fields" do
    quote = Quote.new
    assert_not quote.save, "Saved the quote without required fields"
  end

  test "should calculate correct total value" do
    quote = quotes(:one)  # Using fixtures
    expected_total = quote.subtotal + quote.waste_price + quote.margin_price
    assert_equal expected_total, quote.total_quote_value
  end
end
