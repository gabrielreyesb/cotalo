class QuoteExtra < ApplicationRecord
  belongs_to :quote
  belongs_to :extra

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :ensure_decimal_precision

  def price=(value)
    super(value.to_f.round(2))
  end

  def total_price
    (extra.price * quantity).round(2)
  end

  private

  def ensure_decimal_precision
    self.price = self.price.to_f.round(2) if self.price
  end
end 