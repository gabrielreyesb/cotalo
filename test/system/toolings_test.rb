require "application_system_test_case"

class ToolingsTest < ApplicationSystemTestCase
  setup do
    @tooling = toolings(:one)
  end

  test "visiting the index" do
    visit toolings_url
    assert_selector "h1", text: "Toolings"
  end

  test "should create tooling" do
    visit toolings_url
    click_on "New tooling"

    fill_in "Description", with: @tooling.description
    fill_in "Price", with: @tooling.price
    fill_in "Unit", with: @tooling.unit_id
    click_on "Create Tooling"

    assert_text "Tooling was successfully created"
    click_on "Back"
  end

  test "should update Tooling" do
    visit tooling_url(@tooling)
    click_on "Edit this tooling", match: :first

    fill_in "Description", with: @tooling.description
    fill_in "Price", with: @tooling.price
    fill_in "Unit", with: @tooling.unit_id
    click_on "Update Tooling"

    assert_text "Tooling was successfully updated"
    click_on "Back"
  end

  test "should destroy Tooling" do
    visit tooling_url(@tooling)
    click_on "Destroy this tooling", match: :first

    assert_text "Tooling was successfully destroyed"
  end
end
