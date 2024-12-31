require "application_system_test_case"

class QuotesTest < ApplicationSystemTestCase
  test "creating a new quote" do
    visit new_quote_url
    
    fill_in "Cantidad de piezas", with: "1000"
    fill_in "Ancho del producto", with: "10"
    fill_in "Largo del producto", with: "20"
    select "Caple 90x70", from: "Material principal"
    
    click_on "Calcular productos"
    
    assert_text "Pliegos necesarios:"
    assert_text "Precio material:"
  end
end 