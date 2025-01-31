class ApiKeysController < ApplicationController
  def edit
    Rails.logger.info "==== Rendering API Keys edit form ===="
  end

  def update
    Rails.logger.info "==== API Keys Update Action Started ===="
    Rails.logger.info "Params: #{params.inspect}"
    
    if params[:pipedrive_api_key].present?
      begin
        Rails.logger.info "Attempting to update API key"
        update_env_file(params[:pipedrive_api_key])
        Rails.logger.info "API key updated successfully"
        redirect_to root_path, notice: 'Clave API de Pipedrive actualizada exitosamente.'
      rescue => e
        Rails.logger.error "Error updating API key: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_to edit_api_keys_path, alert: 'Error al actualizar la clave API.'
      end
    else
      Rails.logger.warn "No API key provided in params"
      redirect_to edit_api_keys_path, alert: 'La clave API no puede estar vacía.'
    end
  end

  private

  def update_env_file(new_api_key)
    Rails.logger.info "==== Starting ENV file update ===="
    env_file_path = Rails.root.join('.env')
    
    unless File.exist?(env_file_path)
      Rails.logger.info "Creating new .env file"
      FileUtils.touch(env_file_path)
    end
    
    begin
      env_contents = File.read(env_file_path)
      Rails.logger.info "Successfully read .env file"
      
      if env_contents.match?(/^PIPEDRIVE_API_KEY=/)
        Rails.logger.info "Updating existing API key"
        updated_contents = env_contents.gsub(/^PIPEDRIVE_API_KEY=.*$/, "PIPEDRIVE_API_KEY=#{new_api_key}")
      else
        Rails.logger.info "Adding new API key"
        updated_contents = env_contents.present? ? env_contents + "\n" : ""
        updated_contents += "PIPEDRIVE_API_KEY=#{new_api_key}"
      end
      
      File.write(env_file_path, updated_contents)
      Rails.logger.info "Successfully wrote to .env file"
      
      Dotenv.load
      Rails.logger.info "Reloaded environment variables"
    rescue => e
      Rails.logger.error "Error in update_env_file: #{e.message}"
      raise e
    end
  end
end 