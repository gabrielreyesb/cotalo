class QuoteMaterial < ApplicationRecord
  belongs_to :quote
  belongs_to :material, optional: true

  validates :total_price, presence: true
  validates :material_id, presence: true, unless: :is_manual?
  validates :manual_description, presence: true, if: :is_manual?
  validates :manual_unit, presence: true, if: :is_manual?
  validate :only_one_main_material_per_quote

  private

  def only_one_main_material_per_quote
    return unless is_main?
    
    existing_main = quote.quote_materials.where(is_main: true)
    existing_main = existing_main.where.not(id: id) if persisted?
    
    if existing_main.exists?
      errors.add(:is_main, "Solo puede haber un material principal por cotización")
    end
  end
end 