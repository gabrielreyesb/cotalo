class AppSetting < ApplicationRecord
  belongs_to :user
  has_one_attached :logo
  
  validates :key, presence: true, uniqueness: { scope: :user_id }
  validates :value_type, inclusion: { in: %w[string number array json logo] }
  
  # Basic file size validation
  validate :logo_validation, if: :logo_attached?

  # Serialize array and json values
  serialize :value, JSON

  # Categories
  CATEGORIES = {
    financial: 'financial',
    pdf: 'pdf',
    appearance: 'appearance'  # Add new category for appearance settings
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
    },
    logo: { 
      default: 'cotalo.jpg',  # Set default to the existing Cotalo logo
      type: 'logo', 
      category: CATEGORIES[:appearance] 
    }
  }

  # Class methods to manage settings
  class << self
    def get(key, user)
      setting = user.app_settings.find_by(key: key.to_s)
      
      # Special handling for logo
      if key.to_sym == :logo
        return setting&.logo&.attached? ? setting.logo : ActionController::Base.helpers.asset_path(SETTINGS[:logo][:default])
      end
      
      # Regular handling for other settings
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
      
      if SETTINGS[key_sym][:type] == 'logo'
        setting.logo.attach(value) if value.present?
      else
        setting.value = value
      end
      
      setting.value_type = SETTINGS[key_sym][:type]
      setting.category = SETTINGS[key_sym][:category]
      setting.save
    end
  end

  private

  def logo_attached?
    logo.attached?
  end

  def logo_validation
    if logo.attached?
      if logo.blob.byte_size > 5.megabytes
        errors.add(:logo, 'must be less than 5MB')
      end

      acceptable_types = ['image/png', 'image/jpeg', 'image/jpg']
      unless acceptable_types.include?(logo.content_type)
        errors.add(:logo, 'must be PNG or JPEG')
      end
    end
  end
end 