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
  
      # Instead of rendering a partial, inspect the response data:
      render plain: data.inspect 
    else
      render plain: "API Error: #{response.code} - #{response.body}"
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