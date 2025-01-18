require "application_system_test_case"

class UnitEquivalencesTest < ApplicationSystemTestCase
  setup do
    @unit_equivalence = unit_equivalences(:one)
  end

  test "visiting the index" do
    visit unit_equivalences_url
    assert_selector "h1", text: "Unit equivalences"
  end

  test "should create unit equivalence" do
    visit unit_equivalences_url
    click_on "New unit equivalence"

    fill_in "Conversion factor", with: @unit_equivalence.conversion_factor
    fill_in "Unit one", with: @unit_equivalence.unit_one
    fill_in "Unit two", with: @unit_equivalence.unit_two
    click_on "Create Unit equivalence"

    assert_text "Unit equivalence was successfully created"
    click_on "Back"
  end

  test "should update Unit equivalence" do
    visit unit_equivalence_url(@unit_equivalence)
    click_on "Edit this unit equivalence", match: :first

    fill_in "Conversion factor", with: @unit_equivalence.conversion_factor
    fill_in "Unit one", with: @unit_equivalence.unit_one
    fill_in "Unit two", with: @unit_equivalence.unit_two
    click_on "Update Unit equivalence"

    assert_text "Unit equivalence was successfully updated"
    click_on "Back"
  end

  test "should destroy Unit equivalence" do
    visit unit_equivalence_url(@unit_equivalence)
    click_on "Destroy this unit equivalence", match: :first

    assert_text "Unit equivalence was successfully destroyed"
  end
end
