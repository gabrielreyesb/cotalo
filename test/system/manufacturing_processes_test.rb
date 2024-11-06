require "application_system_test_case"

class ManufacturingProcessesTest < ApplicationSystemTestCase
  setup do
    @manufacturing_process = manufacturing_processes(:one)
  end

  test "visiting the index" do
    visit manufacturing_processes_url
    assert_selector "h1", text: "Manufacturing processes"
  end

  test "should create manufacturing process" do
    visit manufacturing_processes_url
    click_on "New manufacturing process"

    fill_in "Description", with: @manufacturing_process.description
    fill_in "Price", with: @manufacturing_process.price
    fill_in "Unit", with: @manufacturing_process.unit_id
    click_on "Create Manufacturing process"

    assert_text "Manufacturing process was successfully created"
    click_on "Back"
  end

  test "should update Manufacturing process" do
    visit manufacturing_process_url(@manufacturing_process)
    click_on "Edit this manufacturing process", match: :first

    fill_in "Description", with: @manufacturing_process.description
    fill_in "Price", with: @manufacturing_process.price
    fill_in "Unit", with: @manufacturing_process.unit_id
    click_on "Update Manufacturing process"

    assert_text "Manufacturing process was successfully updated"
    click_on "Back"
  end

  test "should destroy Manufacturing process" do
    visit manufacturing_process_url(@manufacturing_process)
    click_on "Destroy this manufacturing process", match: :first

    assert_text "Manufacturing process was successfully destroyed"
  end
end
