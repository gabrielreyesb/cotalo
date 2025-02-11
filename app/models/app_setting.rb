class AppSetting < ApplicationRecord
  belongs_to :user
  
  validates :key, presence: true, uniqueness: { scope: :user_id }
  validates :value_type, inclusion: { in: %w[string number array json] }
  
  # Serialize array and json values
  serialize :value, JSON

  # Categories
  CATEGORIES = {
    financial: 'financial',
    pdf: 'pdf'
  }

  # Define settings with their defaults
  SETTINGS = {
    waste_percentage: { default: 10, type: 'number', category: CATEGORIES[:financial] },
    margin_percentage: { default: 15, type: 'number', category: CATEGORIES[:financial] },
    width_margin: { default: 3, type: 'number', category: CATEGORIES[:financial] },
    length_margin: { default: 3, type: 'number', category: CATEGORIES[:financial] },
    sale_conditions: { 
      default: [
        'LAS ENTREGAS PUEDE VARIAR +/- 10% DE LA CANTIDAD SOLICITADA.',
        'TIEMPO DE ENTREGA: DESPUÉS AUTORIZAR LA PRINT CARD SE ENTREGARÁ EL PRODUCTO EN UN MÁXIMO DE 30 DÍAS Y 21 DÍAS EN REPETICIONES.',
        'CONDICIÓN DE PAGO: CONTADO',
        'COTIZACIÓN CON VALIDEZ DE 30 DÍAS.'
      ], 
      type: 'array',
      category: CATEGORIES[:pdf]
    },
    signature_info: {
      default: {
        name: '',
        email: '',
        phone: '',
        whatsapp: ''
      },
      type: 'json',
      category: CATEGORIES[:pdf]
    }
  }

  # Class methods to manage settings
  class << self
    def get(key, user)
      setting = user.app_settings.find_by(key: key.to_s)
      return SETTINGS[key][:default] if setting.nil?
      
      case setting.value_type
      when 'number'
        setting.value.to_f
      else
        setting.value
      end
    end

    def set(key, value, user)
      key_sym = key.to_sym  # Convert string key to symbol
      return unless SETTINGS.key?(key_sym)  # Check if it's a valid setting
      
      setting = user.app_settings.find_or_initialize_by(key: key.to_s)
      setting.value = value
      setting.value_type = SETTINGS[key_sym][:type]
      setting.category = SETTINGS[key_sym][:category]
      setting.save
    end
  end
end 