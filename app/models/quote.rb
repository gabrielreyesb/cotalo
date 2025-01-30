class Quote < ApplicationRecord
    belongs_to :user
    has_many :quote_materials, dependent: :destroy
    has_many :quote_processes, dependent: :destroy
    has_many :quote_extras, dependent: :destroy
    has_many :materials, through: :quote_materials
    has_many :manufacturing_processes, through: :quote_processes
    has_many :extras, through: :quote_extras

    accepts_nested_attributes_for :quote_materials, allow_destroy: true
    accepts_nested_attributes_for :quote_processes, allow_destroy: true
    accepts_nested_attributes_for :quote_extras, allow_destroy: true

    # Basic validations
    validates :user, presence: true

    # Validations in specific order
    validate :validate_fields_in_order
    validate :validate_materials

    private

    def validate_fields_in_order
      if projects_name.blank?
        errors.add(:projects_name, "can't be blank")
        return
      end

      if product_name.blank?
        errors.add(:product_name, "can't be blank")
        return
      end

      if customer_name.blank?
        errors.add(:customer_name, "can't be blank")
        return
      end

      if customer_organization.blank?
        errors.add(:customer_organization, "can't be blank")
        return
      end

      if customer_email.blank?
        errors.add(:customer_email, "can't be blank")
        return
      elsif !URI::MailTo::EMAIL_REGEXP.match?(customer_email)
        errors.add(:customer_email, "is invalid")
        return
      end

      if product_quantity.blank?
        errors.add(:product_quantity, "can't be blank")
        return
      elsif product_quantity.to_f <= 0
        errors.add(:product_quantity, "must be greater than 0")
        return
      end

      if product_width.blank?
        errors.add(:product_width, "can't be blank")
        return
      elsif product_width.to_f <= 0
        errors.add(:product_width, "must be greater than 0")
        return
      end

      if product_length.blank?
        errors.add(:product_length, "can't be blank")
        return
      elsif product_length.to_f <= 0
        errors.add(:product_length, "must be greater than 0")
        return
      end
    end

    def validate_materials
      return if quote_materials.empty?

      quote_materials.each do |quote_material|
        next if quote_material.is_manual
        
        if quote_material.material_id.blank?
          errors.add(:base, "material_required")
          return
        end
      end
    end

    # Scope to find quotes belonging to a specific user
    scope :for_user, ->(user) { where(user: user) }

    def total_cost
        material_cost + process_cost + extra_cost
    end

    def material_cost
        quote_materials.sum(&:total_cost)
    end

    def process_cost
        quote_processes.sum(&:total_cost)
    end

    def extra_cost
        extras.to_f
    end
end