require "application_system_test_case"
require "webmock"
WebMock.disable_net_connect!(allow_localhost: true)

class QuotesTest < ApplicationSystemTestCase
  # No fixtures or database interactions are needed here.
  # If authentication is required, you can stub it out in the setup.
  setup do
    # Example: bypass authentication if needed.
    # allow_any_instance_of(ApplicationController).to receive(:authenticate_user!).and_return(true)
  end

  test "search for customer via Buscar en Pipedrive" do
    # Stub the external API call.
    # Adjust the URL regexp and the response body to match your actual API call.
    stub_request(:get, /pipedrive/).to_return(
      status: 200,
      body: '{"data": {"customer": {"name": "John Doe", "info": "Some info"}}}',
      headers: { "Content-Type" => "application/json" }
    )
    
    # Visit the calculate page where the form is rendered.
    visit calculate_quotes_path

    # Fill in the required fields.
    fill_in "Nombre del proyecto:", with: "Test Project"
    fill_in "Cliente:", with: "María José Pérez"

    # Click the Buscar en Pipedrive button.
    click_on "Buscar en Pipedrive"

    # Wait for the customer search result to appear.
    # This assumes that your JS updates an element with the id "customer-info" with the result.
    assert_selector "#customer-info", text: "John Doe", wait: 5
  end
end 