require 'dotenv'
require 'platform-api'

class ApiKeysController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin_user

  def edit
    Rails.logger.info "==== Rendering API Keys edit form ===="
  end

  def update
    Rails.logger.info "==== API Keys Update Action Started ===="
    Rails.logger.info "Params: #{params.inspect}"
    
    if params[:pipedrive_api_key].present?
      begin
        Rails.logger.info "Attempting to update API key"
        new_api_key = params[:pipedrive_api_key]

        unless valid_pipedrive_api_key?(new_api_key)
          redirect_to edit_api_keys_path, alert: 'Invalid API key format'
          return
        end

        if Rails.env.production?
          update_heroku_config(new_api_key)
        else
          update_env_file(new_api_key)
        end
        
        # Update environment variable for current session
        ENV['PIPEDRIVE_API_KEY'] = new_api_key
        
        Rails.logger.info "API key updated successfully"
        redirect_to root_path, notice: 'Pipedrive API key updated successfully.'
      rescue => e
        Rails.logger.error "Error updating API key: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        redirect_to edit_api_keys_path, alert: 'Error updating API key.'
      end
    else
      Rails.logger.warn "No API key provided in params"
      redirect_to edit_api_keys_path, alert: 'API key cannot be empty.'
    end
  end

  private

  def require_admin_user
    unless current_user.admin?
      redirect_to root_path, alert: 'Unauthorized access'
    end
  end

  def update_heroku_config(new_api_key)
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
    heroku.config_var.update(ENV['HEROKU_APP_NAME'], {
      'PIPEDRIVE_API_KEY' => new_api_key
    })
  rescue => e
    Rails.logger.error "Heroku API Error: #{e.message}"
    raise "Failed to update Heroku config"
  end

  def valid_pipedrive_api_key?(key)
    key.present? && key.length >= 32 && key =~ /^[a-f0-9]+$/
  end

  def update_env_file(new_api_key)
    begin
      Dotenv.load
      File.open('.env', 'w') do |f|
        f.puts "PIPEDRIVE_API_KEY=#{new_api_key}"
      end
      true
    rescue => e
      Rails.logger.error "Error in update_env_file: #{e.message}"
      false
    end
  end
end 