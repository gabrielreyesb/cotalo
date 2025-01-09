require 'net/http'
require 'uri'
require 'json'

class QuotesController < ApplicationController
  protect_from_forgery with: :exception

  def calculate
    @quote = Quote.new
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
      
      unless ENV['PIPEDRIVE_API_KEY']
        render json: { error: "Pipedrive API key not configured." }, 
               status: :internal_server_error
        return
      end

      api_token = ENV['PIPEDRIVE_API_KEY']
      url = URI("https://api.pipedrive.com/v1/persons/search?term=#{CGI.escape(customer_name)}&api_token=#{api_token}")
      
      response = Net::HTTP.get_response(url)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        results = []

        if data['data'] && data['data']['items']
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
        render json: { error: "Pipedrive API error" }, status: :unprocessable_entity
      end
      
    rescue StandardError => e
      Rails.logger.error "Error in search_customer: #{e.class} - #{e.message}"
      render json: { error: "Internal server error", message: e.message }, status: :internal_server_entity
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
      :total_quote_value, 
      :product_value_per_piece,
      :comments,
      :product_name,
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