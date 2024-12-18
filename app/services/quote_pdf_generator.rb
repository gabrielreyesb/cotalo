class QuotePdfGenerator
  include ActionView::Helpers::NumberHelper

  def initialize(quote)
    @quote = quote
  end

  def generate
    Prawn::Document.new(page_size: "LETTER", margin: 50) do |pdf|
      # Add logo
      pdf.image "#{Rails.root}/app/assets/images/logo.png", width: 200, position: :left
      pdf.move_down 20

      # Add date on the right
      pdf.text "Guadalajara, Jalisco. A #{Time.current.strftime('%d de %B del %Y').upcase}", align: :right
      pdf.move_down 30

      # Client Info
      pdf.text "CLIENTE: #{@quote.customer_name}", style: :bold
      pdf.text "COTIZACIÓN PROYECTO: #{@quote.projects_name}"
      pdf.text "PRODUCTOS: 1"
      pdf.move_down 20

      # Main table
      items = [
        [
          { content: "PRODUCTO", background_color: "EEEEEE", align: :center },
          { content: "MEDIDA\nINTERNAS MM\n(L, A, AL)", background_color: "EEEEEE", align: :center },
          { content: "RESISTENCIA", background_color: "EEEEEE", align: :center },
          { content: "PAPEL", background_color: "EEEEEE", align: :center },
          { content: "PEGUE", background_color: "EEEEEE", align: :center },
          { content: "IMPRESIÓN", background_color: "EEEEEE", align: :center },
          { content: "IMPRESIÓN\nINTERIOR", background_color: "EEEEEE", align: :center },
          { content: "TERMINADO", background_color: "EEEEEE", align: :center },
          { content: "CANTIDAD", background_color: "EEEEEE", align: :center },
          { content: "PRECIO", background_color: "EEEEEE", align: :center }
        ]
      ]

      # Add single product row
      items << [
        "Caja regular individual 750 ml",
        "75 x 75 x 335",
        "22 PUNTOS",
        "CARTULINA METALIZADA",
        "Lineal + Fondo Automático",
        "3 Pantones",
        "NO APLICA",
        "Plástico Mate y Barniz UV",
        @quote.product_quantity,
        number_to_currency(@quote.total_quote_value, unit: "$")
      ]

      pdf.table(items, width: pdf.bounds.width) do |t|
        t.cells.padding = 10
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
        t.cells.align = :center
      end

      pdf.move_down 20

      # Additional costs table
      pdf.text "COSTOS ADICIONALES", style: :bold
      costs = [
        ["HERRAMENTALES", "Calado Laser", number_to_currency(7000, unit: "$")],
        ["SUAJE", "", number_to_currency(7000, unit: "$")],
        ["PLACAS DE IMPRESIÓN", "", number_to_currency(250, unit: "$")],
        ["REALCE", "", number_to_currency(4000, unit: "$")]
      ]

      pdf.table(costs, width: 300) do |t|
        t.cells.padding = 5
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
      end

      pdf.move_down 30

      # Terms and conditions
      pdf.text "CONDICIONES DE VENTA", style: :bold
      pdf.text "• LAS ENTREGAS PUEDE VARIAR +/- 10% DE LA CANTIDAD SOLICITADA."
      pdf.text "• TIEMPO DE ENTREGA: DESPUÉS AUTORIZAR LA PRINT CARD SE ENTREGARÁ EL PRODUCTO EN UN MÁXIMO DE 30 DÍAS Y 21 DÍAS EN REPETICIONES."
      pdf.text "• CONDICIÓN DE PAGO: CONTADO"
      pdf.text "• COTIZACIÓN CON VALIDEZ DE 30 DÍAS."

      pdf.move_down 20

      # Contact info
      pdf.text "Jonathan Gabriel Rubio Huerta", style: :bold
      pdf.text "CORREO: jonathanrubio@surtibox.com"
      pdf.text "CEL/TEL: 3311764022 / 33 2484 9954  WHATSAPP: 3311764022"

      # Footer
      pdf.text "Fabricamos con materiales sustentables que protegen al medio ambiente...", 
               color: "008000", 
               align: :center,
               style: :italic
    end
  end
end 