class QuotePdfGenerator
  include ActionView::Helpers::NumberHelper

  def initialize(quote)
    @quote = quote
  end

  def generate
    Prawn::Document.new(
      page_size: "LETTER", 
      page_layout: :landscape,
      margin: [40, 20, 40, 20]  # [top, right, bottom, left]
    ) do |pdf|
      # Add logo if exists
      logo_path = "#{Rails.root}/app/assets/images/logo.png"
      pdf.image logo_path, width: 120, position: :left if File.exist?(logo_path)
      
      # Add date on the right with line below
      pdf.text "Guadalajara, Jalisco. A #{Time.current.strftime('%d de %B').upcase} del #{Time.current.year}", align: :right, size: 9
      pdf.stroke_horizontal_rule
      pdf.move_down 15

      # Add box watermark if exists
      watermark_path = "#{Rails.root}/app/assets/images/box_watermark.png"
      if File.exist?(watermark_path)
        pdf.create_stamp("background") do
          pdf.image watermark_path, at: [300, 400], width: 400, opacity: 0.2
        end
        pdf.stamp("background")
      end

      # Client Info
      pdf.text "CLIENTE: #{@quote.customer_name.upcase}", style: :bold, size: 9
      pdf.text "COTIZACIÓN PROYECTO: #{@quote.projects_name.upcase}", size: 9
      pdf.text "PRODUCTOS: #{@quote.quote_materials.count}", size: 9
      pdf.move_down 10

      # Main table
      items = [
        [
          { content: "PRODUCTO", background_color: "EEEEEE" },
          { content: "MEDIDA\nINTERNAS MM\n(L, A, AL)", background_color: "EEEEEE" },
          { content: "RESISTENCIA", background_color: "EEEEEE" },
          { content: "PAPEL", background_color: "EEEEEE" },
          { content: "PEGUE", background_color: "EEEEEE" },
          { content: "IMPRESIÓN", background_color: "EEEEEE" },
          { content: "IMPRESIÓN\nINTERIOR", background_color: "EEEEEE" },
          { content: "TERMINADO", background_color: "EEEEEE" },
          { content: "CANTIDAD", background_color: "EEEEEE" },
          { content: "PRECIO", background_color: "EEEEEE" }
        ]
      ]

      # Add product rows
      @quote.quote_materials.each do |material|
        items << [
          "Caja regular individual 750 ml",
          "75 x 75 x 335",
          "22 PUNTOS",
          "CARTULINA METALIZADA",
          "Lineal + Fondo Automático",
          "3 Pantones",
          "NO APLICA",
          "Plástico Mate y\nBarniz UV",
          material.products_per_sheet,
          number_to_currency(material.total_price, unit: "$")
        ]
      end

      # Add IVA NO INCLUIDO row
      items << [{ content: "IVA NO INCLUIDO", colspan: 10, align: :right }]

      pdf.table(items, width: pdf.bounds.width) do |t|
        t.cells.padding = 3
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
        t.cells.align = :center
        t.cells.size = 8
        
        # Wider column widths due to smaller side margins
        t.column_widths = {
          0 => 110,  # Producto
          1 => 65,   # Medidas
          2 => 65,   # Resistencia
          3 => 85,   # Papel
          4 => 85,   # Pegue
          5 => 65,   # Impresión
          6 => 65,   # Imp. Int.
          7 => 85,   # Terminado
          8 => 50,   # Cantidad
          9 => 65    # Precio
        }
      end

      pdf.move_down 15

      # Additional costs table
      costs = [
        ["HERRAMENTALES", "Calado Laser", number_to_currency(7000, unit: "$")],
        ["SUAJE", "", number_to_currency(7000, unit: "$")],
        ["PLACAS DE IMPRESIÓN", "$ 250 x color", ""],
        ["REALCE", "", number_to_currency(4000, unit: "$")]
      ]

      pdf.table(costs, width: 280) do |t|
        t.cells.padding = 3
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
        t.cells.size = 8
      end

      pdf.move_down 15

      # Terms and conditions
      pdf.text "CONDICIONES DE VENTA", style: :bold, size: 8
      pdf.text "• LAS ENTREGAS PUEDE VARIAR +/- 10% DE LA CANTIDAD SOLICITADA.", size: 8
      pdf.text "• TIEMPO DE ENTREGA: DESPUÉS AUTORIZAR LA PRINT CARD SE ENTREGARÁ EL PRODUCTO EN UN MÁXIMO DE 30 DÍAS Y 21 DÍAS EN REPETICIONES.", size: 8
      pdf.text "• CONDICIÓN DE PAGO: CONTADO", size: 8
      pdf.text "• COTIZACIÓN CON VALIDEZ DE 30 DÍAS.", size: 8

      pdf.move_down 15

      # Contact info with clickable email
      pdf.text "Jonathan Gabriel Rubio Huerta", style: :bold, size: 8
      pdf.fill_color "0000FF"
      pdf.text "CORREO: jonathanrubio@surtibox.com", 
               size: 8, 
               link: "mailto:jonathanrubio@surtibox.com"
      pdf.fill_color "000000"
      pdf.text "CEL/TEL: 3311764022 / 33 2484 9954  WHATSAPP: 3311764022", size: 8

      # Add horizontal line
      pdf.stroke_horizontal_rule
      pdf.move_down 8

      # Footer with logos and green text - only add images if they exist
      footer_y = 40
      footer_images = {
        fsc: "#{Rails.root}/app/assets/images/fsc_logo.png",
        fda: "#{Rails.root}/app/assets/images/fda_logo.png",
        qr: "#{Rails.root}/app/assets/images/qr_code.png"
      }

      x_position = pdf.bounds.width - 180
      footer_images.each do |key, path|
        if File.exist?(path)
          pdf.image path, at: [x_position, footer_y], width: 40
          x_position += 50
        end
      end

      pdf.text_box "Fabricamos con materiales sustentables que protegen al medio ambiente...", 
                   at: [0, 35],
                   width: pdf.bounds.width - 200,
                   color: "008000", 
                   align: :left,
                   style: :italic,
                   size: 8
    end
  end
end 