require 'net/http'
require 'uri'
require 'json'

class QuotesController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_quote, only: [:show, :edit, :update, :destroy]

  def calculate
    @quote = if params[:quote_id]
              current_user.quotes.includes(:quote_materials, :quote_processes, :manufacturing_processes,
                           quote_extras: :extra).find(params[:quote_id])
            else
              current_user.quotes.build
            end
    
    # Set default values if configurations are missing
    @configuration_margin_width = current_user.general_configurations.find_by(description: 'Margen ancho').try(:amount) || 0
    @configuration_margin_length = current_user.general_configurations.find_by(description: 'Margen largo').try(:amount) || 0
    @waste_config = current_user.general_configurations.find_by(description: 'merma') || current_user.general_configurations.build(description: 'merma', amount: 0)
    @margin_config = current_user.general_configurations.find_by(description: 'margen') || current_user.general_configurations.build(description: 'margen', amount: 0)

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
    @quote = current_user.quotes.build
    @quote.quote_processes.build
    @materials = Material.all
  end

  def create
    @quote = current_user.quotes.build(quote_params)
    @materials = Material.all

    # Add debugging
    Rails.logger.debug "==== Quote Creation Debug ===="
    Rails.logger.debug "Quote params after permit: #{quote_params.inspect}"
    Rails.logger.debug "Quote valid? #{@quote.valid?}"
    
    # Debug associations - Add nil checks
    if quote_params[:quote_processes_attributes].present?
      ids = quote_params[:quote_processes_attributes].map do |_, attrs|
        attrs[:manufacturing_process_id] if attrs
      end.compact
      Rails.logger.debug "Manufacturing Process IDs: #{ids}"
    end

    if quote_params[:quote_materials_attributes].present?
      ids = quote_params[:quote_materials_attributes].map do |_, attrs|
        attrs[:material_id] if attrs
      end.compact
      Rails.logger.debug "Material IDs: #{ids}"
    end

    if quote_params[:quote_extras_attributes].present?
      ids = quote_params[:quote_extras_attributes].map do |_, attrs|
        attrs[:extra_id] if attrs
      end.compact
      Rails.logger.debug "Extra IDs: #{ids}"
    end

    if @quote.save
      redirect_to root_path, notice: 'Quote was successfully created.'
    else
      respond_to do |format|
        format.turbo_stream do
          error_messages = format_error_messages(@quote.errors)
          render turbo_stream: turbo_stream.update(
            "dynamic-messages",
            "<div data-controller='alert' 
                  data-alert-message-value='#{ERB::Util.html_escape(error_messages)}' 
                  data-alert-type-value='error'></div>".html_safe
          )
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def search_customer
    begin
      customer_name = params[:quote][:customer_name]
      Rails.logger.debug "Starting customer search for: #{customer_name}"
      
      # Add more detailed debugging
      Rails.logger.debug "==== Environment Variables Debug ===="
      Rails.logger.debug "PIPEDRIVE_API_KEY raw value: #{ENV['PIPEDRIVE_API_KEY']}"
      Rails.logger.debug "PIPEDRIVE_API_KEY present?: #{ENV['PIPEDRIVE_API_KEY'].present?}"
      Rails.logger.debug "PIPEDRIVE_API_KEY nil?: #{ENV['PIPEDRIVE_API_KEY'].nil?}"
      Rails.logger.debug "PIPEDRIVE_API_KEY empty?: #{ENV['PIPEDRIVE_API_KEY'].empty?}"
      Rails.logger.debug "All ENV keys: #{ENV.keys.sort}"
      Rails.logger.debug "=================================="
      
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
    respond_to do |format|
      format.html
      format.json { 
        render json: @quote.to_json(
          include: {
            quote_materials: {
              methods: [:material],
              only: [:id, :material_id, :products_per_sheet, :sheets_needed, 
                    :square_meters, :total_price, :is_manual, :manual_description, 
                    :manual_unit, :is_main, :price_per_unit, :width, :length, 
                    :comments]
            },
            quote_processes: {
              include: {
                manufacturing_process: {
                  include: :unit
                }
              },
              only: [:id, :manufacturing_process_id, :price, :unit_price, :comments]
            },
            quote_extras: {
              methods: [:extra],
              only: [:id, :extra_id, :quantity, :price, :comments]
            }
          }
        )
      }
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
    Rails.logger.debug "Current user ID: #{current_user.id}"
    Rails.logger.debug "Current user email: #{current_user.email}"
    @quotes = current_user.quotes.order(created_at: :desc)
    Rails.logger.debug "Found #{@quotes.length} quotes for user"
  end

  def update
    respond_to do |format|
      if @quote.update(quote_params)
        format.html { redirect_to root_path, notice: 'Quote was successfully updated.' }
        format.json { render json: { success: true, redirect_url: root_path } }
        format.turbo_stream { redirect_to root_path, notice: 'Quote was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @quote.errors }, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update("quote-form", 
            partial: "quotes/form", 
            locals: { quote: @quote }
          ), 
          status: :unprocessable_entity 
        }
      end
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_url, notice: 'Quote was successfully destroyed.'
  end

  def edit
    redirect_to calculate_quotes_path(quote_id: @quote.id)
  end

  private

  def set_quote
    @quote = current_user.quotes.find(params[:id])
  end

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
      :price_per_piece_before_margin,
      quote_processes_attributes: [
        :id, 
        :manufacturing_process_id, 
        :price, 
        :unit_price, 
        :_destroy,
        :comments
      ],
      quote_materials_attributes: [
        :id, 
        :material_id,
        :products_per_sheet, 
        :sheets_needed,
        :square_meters, 
        :total_price, 
        :_destroy,
        :is_manual, 
        :manual_description, 
        :manual_unit, 
        :is_main,
        :price_per_unit, 
        :width, 
        :length,
        :manual_width,
        :manual_length,
        :comments
      ],
      quote_extras_attributes: [
        :id, 
        :extra_id, 
        :quantity, 
        :price, 
        :_destroy,
        :comments
      ]
    )
  end

  def configuration_margin_width
    @configuration_margin_width ||= current_user.general_configurations.find_by(description: 'Margen ancho').try(:amount)
  end

  def configuration_margin_length
    @configuration_margin_length ||= current_user.general_configurations.find_by(description: 'Margen largo').try(:amount)
  end

  def format_error_messages(errors)
    # Get only the first error message
    error = errors.first
    
    # Translate common error messages
    translated_message = case error.message
      when "can't be blank"
        "es requerido"
      when "is not a number"
        "debe ser un número"
      when "must be greater than 0"
        "debe ser mayor que 0"
      when "is invalid"
        "no es válido"
      when "material_required"
        "Debe seleccionar un material del catálogo o agregar uno manual"
      else
        error.message
    end

    # Format field-specific message
    case error.attribute.to_s
    when 'customer_name'
      "El nombre del cliente #{translated_message}"
    when 'customer_organization'
      "La organización del cliente #{translated_message}"
    when 'customer_email'
      "El correo electrónico #{translated_message}"
    when 'projects_name'
      "El nombre del proyecto #{translated_message}"
    when 'product_name'
      "El nombre del producto #{translated_message}"
    when 'product_quantity'
      "La cantidad de productos #{translated_message}"
    when 'product_width'
      "El ancho del producto #{translated_message}"
    when 'product_length'
      "El largo del producto #{translated_message}"
    when 'base'
      translated_message
    else
      "#{error.attribute.to_s.humanize} #{translated_message}"
    end
  end

end