require "application_system_test_case"

class GeneralConfigurationsTest < ApplicationSystemTestCase
  setup do
    @general_configuration = general_configurations(:one)
  end

  test "visiting the index" do
    visit general_configurations_url
    assert_selector "h1", text: "General configurations"
  end

  test "should create general configuration" do
    visit general_configurations_url
    click_on "New general configuration"

    fill_in "Amount", with: @general_configuration.amount
    fill_in "Description", with: @general_configuration.description
    click_on "Create General configuration"

    assert_text "General configuration was successfully created"
    click_on "Back"
  end

  test "should update General configuration" do
    visit general_configuration_url(@general_configuration)
    click_on "Edit this general configuration", match: :first

    fill_in "Amount", with: @general_configuration.amount
    fill_in "Description", with: @general_configuration.description
    click_on "Update General configuration"

    assert_text "General configuration was successfully updated"
    click_on "Back"
  end

  test "should destroy General configuration" do
    visit general_configuration_url(@general_configuration)
    click_on "Destroy this general configuration", match: :first

    assert_text "General configuration was successfully destroyed"
  end
end
