require "test_helper"

class ManufacturingProcessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manufacturing_process = manufacturing_processes(:one)
  end

  test "should get index" do
    get manufacturing_processes_url
    assert_response :success
  end

  test "should get new" do
    get new_manufacturing_process_url
    assert_response :success
  end

  test "should create manufacturing_process" do
    assert_difference("ManufacturingProcess.count") do
      post manufacturing_processes_url, params: { manufacturing_process: { description: @manufacturing_process.description, price: @manufacturing_process.price, unit_id: @manufacturing_process.unit_id } }
    end

    assert_redirected_to manufacturing_process_url(ManufacturingProcess.last)
  end

  test "should show manufacturing_process" do
    get manufacturing_process_url(@manufacturing_process)
    assert_response :success
  end

  test "should get edit" do
    get edit_manufacturing_process_url(@manufacturing_process)
    assert_response :success
  end

  test "should update manufacturing_process" do
    patch manufacturing_process_url(@manufacturing_process), params: { manufacturing_process: { description: @manufacturing_process.description, price: @manufacturing_process.price, unit_id: @manufacturing_process.unit_id } }
    assert_redirected_to manufacturing_process_url(@manufacturing_process)
  end

  test "should destroy manufacturing_process" do
    assert_difference("ManufacturingProcess.count", -1) do
      delete manufacturing_process_url(@manufacturing_process)
    end

    assert_redirected_to manufacturing_processes_url
  end
end
