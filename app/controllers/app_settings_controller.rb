class AppSettingsController < ApplicationController
  def edit
    @financial_settings = AppSetting::SETTINGS.select { |_, v| v[:category] == AppSetting::CATEGORIES[:financial] }
    @pdf_settings = AppSetting::SETTINGS.select { |_, v| v[:category] == AppSetting::CATEGORIES[:pdf] }
    @appearance_settings = AppSetting::SETTINGS.select { |_, v| v[:category] == AppSetting::CATEGORIES[:appearance] }
  end

  def update
    if params[:logo].present?
      AppSetting.set(:logo, params[:logo], current_user)
    end

    if settings_params.present?
      settings_params.each do |key, value|
        if key == "signature_info"
          AppSetting.set(key, value.to_h, current_user)
        elsif key == "sale_conditions"
          AppSetting.set(key, value.reject(&:blank?), current_user)
        else
          AppSetting.set(key, value, current_user)
        end
      end
    end
      
    redirect_to edit_app_settings_path
  end

  private

  def settings_params
    params.require(:settings).permit(
      :waste_percentage,
      :margin_percentage,
      :width_margin,
      :length_margin,
      sale_conditions: [],
      signature_info: [:name, :email, :phone, :whatsapp]
    )
  end
end 

Rails.application.configure do
  # Disable automatic analysis since we don't need it for logos
  config.active_storage.analyzers = []
  config.active_storage.previewers = []
end 