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
    api_token = Rails.application.credentials.pipedrive[:api_key]
  
    url = URI("https://api.pipedrive.com/v1/persons/search?term=#{CGI.escape(customer_name)}&api_token=#{api_token}")
  
    response = Net::HTTP.get_response(url)
  
    if response.code == '200'
      data = JSON.parse(response.body)
  
      # Check if any results were found
      if data['data'] && data['data']['items'].any?
        @customer = data['data']['items'].first['item']
        # Log the found customer's details (optional)
        logger.debug("Customer found in Pipedrive: #{@customer.inspect}") 
      else
        @customer = nil
        # Log that the customer was not found (optional)
        logger.debug("Customer not found in Pipedrive.") 
      end
    else
      @customer = nil
      # Log the API error response (optional)
      logger.error("Pipedrive API error: #{response.code} - #{response.body}") 
    end
  
    respond_to do |format|
      format.html {
        if @customer
          render partial: 'customer_email', locals: { customer: @customer }
        else
          render partial: 'customer_not_found' 
        end
      }
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
      :manufacturing_process_id, quote_processes_attributes: [:id, :process_id, :destroy], quote_toolings_attributes: [:id, :toolingid, :quantity, :destroy]
    )
  end
end