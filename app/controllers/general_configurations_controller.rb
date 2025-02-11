class GeneralConfigurationsController < ApplicationController
  before_action :set_general_configuration, only: [:show, :edit, :update, :destroy]

  def index
    @general_configurations = current_user.general_configurations.includes(:unit).order(:description)
  end

  def show
  end

  def new
    @general_configuration = current_user.general_configurations.build
  end

  def edit
    @sale_conditions = GeneralConfiguration.find_by(description: 'Condiciones de venta')
    @signature = GeneralConfiguration.find_by(description: 'Firma')
  end

  def create
    @general_configuration = current_user.general_configurations.build(general_configuration_params)

    if @general_configuration.save
      redirect_to general_configurations_path, notice: 'General configuration was successfully created.'
    else
      render :new
    end
  end

  def update
    @config = GeneralConfiguration.find(params[:id])
    if @config.update(config_params)
      redirect_to edit_general_configurations_path, notice: 'Configuración actualizada exitosamente.'
    else
      render :edit
    end
  end

  def destroy
    @general_configuration.destroy
    redirect_to general_configurations_url, notice: 'General configuration was successfully destroyed.'
  end

  private

  def set_general_configuration
    @general_configuration = current_user.general_configurations.find(params[:id])
  end

  def general_configuration_params
    params.require(:general_configuration).permit(:description, :amount, :unit_id)
  end

  def config_params
    params.require(:general_configuration).permit(
      :signature_name, 
      :signature_email, 
      :signature_phone, 
      :signature_whatsapp,
      sale_conditions: []
    )
  end

  def update_env_file(new_api_key)
    env_file_path = Rails.root.join('.env')
    env_contents = File.read(env_file_path)
    
    if env_contents.match?(/^PIPEDRIVE_API_KEY=/)
      # Update existing key
      updated_contents = env_contents.gsub(/^PIPEDRIVE_API_KEY=.*$/, "PIPEDRIVE_API_KEY=#{new_api_key}")
    else
      # Add new key
      updated_contents = env_contents + "\nPIPEDRIVE_API_KEY=#{new_api_key}"
    end
    
    File.write(env_file_path, updated_contents)
    
    # Reload environment variables
    Dotenv.load
  end
end
