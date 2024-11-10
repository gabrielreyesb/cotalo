require "test_helper"

class GeneralConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @general_configuration = general_configurations(:one)
  end

  test "should get index" do
    get general_configurations_url
    assert_response :success
  end

  test "should get new" do
    get new_general_configuration_url
    assert_response :success
  end

  test "should create general_configuration" do
    assert_difference("GeneralConfiguration.count") do
      post general_configurations_url, params: { general_configuration: { amount: @general_configuration.amount, description: @general_configuration.description } }
    end

    assert_redirected_to general_configuration_url(GeneralConfiguration.last)
  end

  test "should show general_configuration" do
    get general_configuration_url(@general_configuration)
    assert_response :success
  end

  test "should get edit" do
    get edit_general_configuration_url(@general_configuration)
    assert_response :success
  end

  test "should update general_configuration" do
    patch general_configuration_url(@general_configuration), params: { general_configuration: { amount: @general_configuration.amount, description: @general_configuration.description } }
    assert_redirected_to general_configuration_url(@general_configuration)
  end

  test "should destroy general_configuration" do
    assert_difference("GeneralConfiguration.count", -1) do
      delete general_configuration_url(@general_configuration)
    end

    assert_redirected_to general_configurations_url
  end
end
