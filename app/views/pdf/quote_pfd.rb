require 'prawn'

class QuotePdf < Prawn::Document
  def initialize(quote)
    super()
    @quote = quote
    generate_quote
  end

  def generate_quote
    font "Helvetica"
    font_size 10

    text "Guadalajara, Jalisco, a #{Date.today.strftime('%d de %B del %Y')}", align: :right
    move_down 10
    text "SURTIBOX", size: 16, style: :bold
    text "Soluciones en empaques y más...", size: 12
  end
end