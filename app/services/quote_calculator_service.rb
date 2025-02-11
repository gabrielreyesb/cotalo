class QuoteCalculatorService
  def initialize(quote, user)
    @quote = quote
    @user = user
    @waste_percentage = AppSetting.get(:waste_percentage, user)
    @margin_percentage = AppSetting.get(:margin_percentage, user)
    @width_margin = AppSetting.get(:width_margin, user)
    @length_margin = AppSetting.get(:length_margin, user)
  end

  def calculate
    # Add margins to dimensions
    total_width = @quote.width + (@width_margin * 2)
    total_length = @quote.length + (@length_margin * 2)

    # Calculate area with margins
    area = total_width * total_length

    # Apply waste percentage
    with_waste = base_price * (1 + (@waste_percentage / 100))

    # Apply margin percentage
    final_price = with_waste * (1 + (@margin_percentage / 100))

    # Rest of your calculations...
  end
end 