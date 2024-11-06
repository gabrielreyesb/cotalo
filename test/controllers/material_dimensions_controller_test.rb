require "test_helper"

class MaterialDimensionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get material_dimensions_show_url
    assert_response :success
  end
end
