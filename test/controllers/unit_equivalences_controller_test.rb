require "test_helper"

class UnitEquivalencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit_equivalence = unit_equivalences(:one)
  end

  test "should get index" do
    get unit_equivalences_url
    assert_response :success
  end

  test "should get new" do
    get new_unit_equivalence_url
    assert_response :success
  end

  test "should create unit_equivalence" do
    assert_difference("UnitEquivalence.count") do
      post unit_equivalences_url, params: { unit_equivalence: { conversion_factor: @unit_equivalence.conversion_factor, unit_one: @unit_equivalence.unit_one, unit_two: @unit_equivalence.unit_two } }
    end

    assert_redirected_to unit_equivalence_url(UnitEquivalence.last)
  end

  test "should show unit_equivalence" do
    get unit_equivalence_url(@unit_equivalence)
    assert_response :success
  end

  test "should get edit" do
    get edit_unit_equivalence_url(@unit_equivalence)
    assert_response :success
  end

  test "should update unit_equivalence" do
    patch unit_equivalence_url(@unit_equivalence), params: { unit_equivalence: { conversion_factor: @unit_equivalence.conversion_factor, unit_one: @unit_equivalence.unit_one, unit_two: @unit_equivalence.unit_two } }
    assert_redirected_to unit_equivalence_url(@unit_equivalence)
  end

  test "should destroy unit_equivalence" do
    assert_difference("UnitEquivalence.count", -1) do
      delete unit_equivalence_url(@unit_equivalence)
    end

    assert_redirected_to unit_equivalences_url
  end
end
