require "test_helper"

class QuotesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get quotes_url
    assert_response :success
  end

  test "should create quote" do
    assert_difference("Quote.count") do
      post quotes_url, params: { 
        quote: { 
          product_quantity: 1000,
          product_width: 10,
          product_length: 20,
          material_id: materials(:one).id
        } 
      }
    end
    assert_redirected_to quote_url(Quote.last)
  end
end
