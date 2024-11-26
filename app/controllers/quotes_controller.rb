require 'net/http'
require 'uri'
require 'json'

class QuotesController < ApplicationController
  protect_from_forgery with: :exception

  def new
    @quote = Quote.new
    @quote.quote_processes.build
    @quote.quote_toolings.build
    @configuration_margin_width = GeneralConfiguration.find_by(description: 'Margen ancho').try(:amount) 
    @configuration_margin_length = GeneralConfiguration.find_by(description: 'Margen largo').try(:amount) 

    respond_to do |format|
      format.html { 
        render 'new', 
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
      format.pdf do
        render pdf: "quote_#{@quote.id}",
               template: 'quotes/show.html.erb',
               layout: 'pdf'
      end
    end
  end

  def create
    @quote = Quote.new(quote_params)
  
    if params[:quote][:customer_name].present?
      search_customer
    elsif @quote.save
      configuration_margin_width = GeneralConfiguration.find_by(description: 'Margen ancho').try(:amount) 
      configuration_margin_length = GeneralConfiguration.find_by(description: 'Margen largo').try(:amount) 
    else
      render :new
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
      :projects_name,
      :length,
      :tooling_id,
      :sub_total_value,
      :waste_value,
      :margin_value,
      :total_value,
      :value_per_piece,
      :customer_organization,
      :config_margin_width, 
      :config_margin_length,
      :manual_material_unit,
      quote_processes_attributes: [:id, :process_id, :destroy], 
      quote_toolings_attributes: [:id, :toolingid, :quantity, :destroy]
    )
  end
end