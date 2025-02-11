class AppSettingsController < ApplicationController
  def edit
    @financial_settings = AppSetting::SETTINGS.select { |_, v| v[:category] == AppSetting::CATEGORIES[:financial] }
    @pdf_settings = AppSetting::SETTINGS.select { |_, v| v[:category] == AppSetting::CATEGORIES[:pdf] }
  end

  def update
    if settings_params.present?
      settings_params.each do |key, value|
        # Handle nested attributes for signature_info
        if key == "signature_info"
          AppSetting.set(key, value.to_h, current_user)
        # Handle array for sale_conditions
        elsif key == "sale_conditions"
          AppSetting.set(key, value.reject(&:blank?), current_user)
        else
          AppSetting.set(key, value, current_user)
        end
      end
      
      respond_to do |format|
        format.html { 
          redirect_to edit_app_settings_path, 
          notice: 'Configuraciones actualizadas exitosamente'
        }
      end
    else
      respond_to do |format|
        format.html { 
          redirect_to edit_app_settings_path, 
          alert: 'No se recibieron configuraciones para actualizar'
        }
      end
    end
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