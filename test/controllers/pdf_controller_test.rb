require "test_helper"

class PdfControllerTest < ActionDispatch::IntegrationTest
  test "should get generate" do
    get pdf_generate_url
    assert_response :success
  end
end
