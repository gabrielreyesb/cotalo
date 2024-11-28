require 'net/http'
require 'uri'
require 'json'

class QuotesController < ApplicationController
  protect_from_forgery with: :exception

  def calculate
    @quote = Quote.new
    @quote.quote_processes.build
    @quote.quote_toolings.build
    @configuration_margin_width = GeneralConfiguration.find_by(description: 'Margen ancho').try(:amount) 
    @configuration_margin_length = GeneralConfiguration.find_by(description: 'Margen largo').try(:amount) 

    respond_to do |format|
      format.html { 
        render 'calculate', 
               locals: { 
                 quote: @quote, 
                 configuration_margin_width: @configuration_margin_width,
                 configuration_margin_length: @configuration_margin_length 
               } 
      }
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          'main-content',
          partial: 'quotes/simple_form',
          locals: { quote: @quote }
        )
      }
    end
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
  
    puts "----------------------------------" 
    puts "Quote params: #{quote_params.inspect}" 
    puts "----------------------------------" 

    if @quote.save
      redirect_to @quote, notice: "Quote was successfully created." 
    else
      render :new, status: :unprocessable_entity 
    end
  end

  def search_customer
    customer_name = params[:quote][:customer_name]
    api_token = Rails.application.credentials.pipedrive[:api_key]
  
    url = URI("https://api.pipedrive.com/v1/persons/search?term=#{CGI.escape(customer_name)}&api_token=#{api_token}")
  
    response = Net::HTTP.get_response(url)
  
    if response.code == '200'
      begin
        data = JSON.parse(response.body)
  
        organizations = []
        if data['data'] && data['data']['items']
          data['data']['items'].each do |item|
            organization_name = item.dig('item', 'organization', 'name')
            organizations << organization_name if organization_name
          end
        end

      respond_to do |format|
        format.html { render json: { organizations: organizations } } 
        format.json { render json: { organizations: organizations } }
      end
  
      rescue JSON::ParserError => e
        logger.error("Error parsing JSON response: #{e.message}")
        render json: { error: "Error parsing JSON response." }, status: :unprocessable_entity 
      end
    else
      logger.error("Pipedrive API error: #{response.code} - #{response.body}")
      render json: { error: "API Error: #{response.code} - #{response.body}" }, status: :unprocessable_entity 
    end
  end


  private

  def quote_params
    params.require(:quote).permit(
      :customer_email,
      :product_quantity,
      :product_width,
      :product_length,
      :material_id,
      :material_unit_id,
      :material_price,
      :products_per_sheet,
      :amount_of_sheets,
      :material_total_price,
      :material_square_meters,
      :subtotal,
      :waste_percentage,
      :margin_percentage,
      :total_quote_value,
      :product_value_per_piece,
      :customer_name,
      :projects_name,
      :customer_organization,
      :manual_material,
      :manual_material_unit_id,
      :manual_material_price, 
      :manual_material_width,
      :manual_material_length,
      :manufacturing_process_id,
      :tooling_id,
      :waste_value,
      :margin_value,
      :total_value,
      :value_per_piece, 
      quote_processes_attributes: [:id, :manufacturing_process_id, :_destroy],
      quote_toolings_attributes: [:id, :tooling_id, :quantity, :_destroy]
    )
  end

end