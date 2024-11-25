require 'net/http'
require 'uri'
require 'json'

class QuotesController < ApplicationController
  protect_from_forgery with: :exception

  def new
    @quote = Quote.new
    @quote.quote_processes.build
    @quote.quote_toolings.build

    respond_to do |format|
      format.html { render 'new' }
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          'main-content',
          partial: 'quotes/simple_form',
          locals: { quote: @quote }
        )
      }
    end
  end

  def create
    @quote = Quote.new(quote_params)
  
    if params[:quote][:customer_name].present?
      search_customer
    elsif @quote.save # Move this elsif block here
      # Handle successful save (e.g., redirect)
      # For example: redirect_to @quote, notice: 'Quote was successfully created.'
    else
      # Handle failure (e.g., render 'new' again)
      render :new
    end
  end

  def search_customer
    customer_name = params[:quote][:customer_name]
    logger.error("-----------------------------------------")
    logger.error("Customer name: #{customer_name}")
    logger.error("-----------------------------------------")

    api_token = Rails.application.credentials.pipedrive[:api_key]
  
    url = URI("https://api.pipedrive.com/v1/persons/search?term=#{CGI.escape(customer_name)}&api_token=#{api_token}")
  
    response = Net::HTTP.get_response(url)
  
    if response.code == '200'
      begin
        data = JSON.parse(response.body)
  
        organizations = []
        if data['data'] && data['data']['items']
          data['data']['items'].each do |item|
            customer = item['item']
            organizations << customer['organization']['name'] if customer['organization']
          end
        else
          logger.debug("No customers found in the API response.")
        end
  
        respond_to do |format|
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
      :width,
      :lenght,
      :pieces,
      :material_id,
      :customer_name,
      :manufacturing_process_id,
      :projects_name,    # Add this
      :length,           # Add this
      :tooling_id,       # Add this
      :sub_total_value, # Add this
      :waste_value,     # Add this
      :margin_value,    # Add this
      :total_value,     # Add this
      :value_per_piece, # Add this
      :customer_organization, # Add this for the new field
      quote_processes_attributes: [:id, :process_id, :destroy], 
      quote_toolings_attributes: [:id, :toolingid, :quantity, :destroy]
    )
  end
end