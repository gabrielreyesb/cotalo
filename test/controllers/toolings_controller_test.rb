require "test_helper"

class ToolingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tooling = toolings(:one)
  end

  test "should get index" do
    get toolings_url
    assert_response :success
  end

  test "should get new" do
    get new_tooling_url
    assert_response :success
  end

  test "should create tooling" do
    assert_difference("Tooling.count") do
      post toolings_url, params: { tooling: { description: @tooling.description, price: @tooling.price, unit_id: @tooling.unit_id } }
    end

    assert_redirected_to tooling_url(Tooling.last)
  end

  test "should show tooling" do
    get tooling_url(@tooling)
    assert_response :success
  end

  test "should get edit" do
    get edit_tooling_url(@tooling)
    assert_response :success
  end

  test "should update tooling" do
    patch tooling_url(@tooling), params: { tooling: { description: @tooling.description, price: @tooling.price, unit_id: @tooling.unit_id } }
    assert_redirected_to tooling_url(@tooling)
  end

  test "should destroy tooling" do
    assert_difference("Tooling.count", -1) do
      delete tooling_url(@tooling)
    end

    assert_redirected_to toolings_url
  end
end
