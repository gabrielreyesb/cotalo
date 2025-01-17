require 'net/http'
require 'uri'
require 'json'

class QuotesController < ApplicationController
  protect_from_forgery with: :exception

  def calculate
    @quote = if params[:quote_id]
              Quote.includes(:quote_materials, :quote_processes, :manufacturing_processes,
                           quote_extras: :extra).find(params[:quote_id])
            else
              Quote.new
            end
    
    @configuration_margin_width = GeneralConfiguration.find_by(description: 'Margen ancho').try(:amount) 
    @configuration_margin_length = GeneralConfiguration.find_by(description: 'Margen largo').try(:amount) 
    @waste_config = GeneralConfiguration.find_by(description: 'merma')
    @margin_config = GeneralConfiguration.find_by(description: 'margen')

    respond_to do |format|
      format.html { 
        render 'calculate', 
               locals: { 
                 quote: @quote, 
                 configuration_margin_width: @configuration_margin_width,
                 configuration_margin_length: @configuration_margin_length,
                 waste_config: @waste_config,
                 margin_config: @margin_config
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
    @quote.quote_processes.build
  end

  def create
    @quote = Quote.new(quote_params)
    
    if @quote.save
      redirect_to root_path, notice: "Cotización creada exitosamente."
    else
      render :calculate, status: :unprocessable_entity
    end
  end

  def search_customer
    begin
      customer_name = params[:quote][:customer_name]
      Rails.logger.debug "Starting customer search for: #{customer_name}"
      
      Rails.logger.debug "Environment variables:"
      Rails.logger.debug "PIPEDRIVE_API_KEY present?: #{ENV['PIPEDRIVE_API_KEY'].present?}"
      Rails.logger.debug "All ENV keys: #{ENV.keys}"
      
      unless ENV['PIPEDRIVE_API_KEY']
        Rails.logger.error "PIPEDRIVE_API_KEY not found in environment variables"
        render json: { error: "Pipedrive API key not configured." }, 
               status: :internal_server_error
        return
      end

      Rails.logger.debug "PIPEDRIVE_API_KEY is present"
      api_token = ENV['PIPEDRIVE_API_KEY']
      url = URI("https://api.pipedrive.com/v1/persons/search?term=#{CGI.escape(customer_name)}&api_token=#{api_token}")
      Rails.logger.debug "Making request to Pipedrive URL: #{url.to_s.gsub(api_token, '[REDACTED]')}"
      
      response = Net::HTTP.get_response(url)
      Rails.logger.debug "Pipedrive response code: #{response.code}"
      Rails.logger.debug "Pipedrive response body: #{response.body}"
      
      if response.code == '200'
        data = JSON.parse(response.body)
        Rails.logger.debug "Successfully parsed JSON response"
        results = []

        if data['data'] && data['data']['items']
          Rails.logger.debug "Found #{data['data']['items'].length} results"
          data['data']['items'].each do |item|
            person = item['item']
            
            email = if person['email']
                     person['email'].is_a?(Array) ? person['email'].first['value'] : person['email']
                   elsif person['emails']
                     person['emails'].is_a?(Array) ? person['emails'].first : person['emails']
                   end

            results << {
              name: person['name'],
              email: email,
              organization: person.dig('organization', 'name'),
              organization_id: person.dig('organization', 'value'),
              person_id: person['id']
            }
          end
        end

        render json: { results: results }
      else
        Rails.logger.error "Pipedrive API error. Response code: #{response.code}, Body: #{response.body}"
        render json: { error: "Pipedrive API error" }, status: :unprocessable_entity
      end
      
    rescue StandardError => e
      Rails.logger.error "Error in search_customer: #{e.class} - #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      render json: { error: "Internal server error", message: e.message }, status: :internal_server_error
    end
  end

  def show
    @quote = Quote.includes(:quote_processes, :manufacturing_processes, 
                           quote_extras: :extra).find(params[:id])
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = QuotePdfGenerator.new(@quote).generate
        send_data pdf.render,
                  filename: "cotizacion_#{@quote.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def index
    @quotes = Quote.order(created_at: :desc)
  end

  def update
    @quote = Quote.find(params[:id])
    Rails.logger.debug "Quote params: #{quote_params.inspect}"
    Rails.logger.debug "Quote processes params: #{quote_params[:quote_processes_attributes]&.inspect}"
    
    if @quote.update(quote_params)
      redirect_to root_path, notice: "Cotización actualizada exitosamente."
    else
      @configuration_margin_width = GeneralConfiguration.find_by(description: 'Margen ancho').try(:amount)
      @configuration_margin_length = GeneralConfiguration.find_by(description: 'Margen largo').try(:amount)
      @waste_config = GeneralConfiguration.find_by(description: 'merma')
      @margin_config = GeneralConfiguration.find_by(description: 'margen')
      render :calculate, status: :unprocessable_entity
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
      :customer_name,
      :projects_name,
      :customer_organization,
      :customer_email,
      :product_quantity,
      :product_width,
      :product_length,
      :subtotal,
      :waste_percentage,
      :margin_percentage,
      :total_quote_value,
      :product_value_per_piece,
      :waste_price,
      :margin_price,
      :comments,
      :product_name,
      :include_extras,
      quote_processes_attributes: [:id, :manufacturing_process_id, :price, :_destroy],
      quote_extras_attributes: [:id, :extra_id, :quantity, :_destroy],
      quote_materials_attributes: [
        :id, :material_id, :products_per_sheet, :sheets_needed, 
        :square_meters, :total_price, :_destroy,
        :is_manual, :manual_description, :manual_unit
      ]
    )
  end

  def configuration_margin_width
    @configuration_margin_width ||= GeneralConfiguration.find_by(description: 'Margen ancho').try(:amount)
  end

  def configuration_margin_length
    @configuration_margin_length ||= GeneralConfiguration.find_by(description: 'Margen largo').try(:amount)
  end

end