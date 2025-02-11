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
      customer_info = [
        ["CLIENTE:", @quote.customer_name.upcase],
        ["EMPRESA:", (@quote.customer_organization || "Sin organización").upcase],
        ["CORREO:", @quote.customer_email],
        ["TELÉFONO:", @quote.customer_phone || "No especificado"],
        ["PROYECTO:", @quote.projects_name.upcase]
      ]

      pdf.table(customer_info, width: 300, cell_style: { 
        borders: [], 
        padding: [2, 5], 
        size: 9,
      }) do |t|
        t.cells.style do |c|
          c.font_style = c.column == 0 ? :bold : :normal
        end
      end

      pdf.move_down 10

      # Main table
      items = [
        [
          { content: "PRODUCTO", background_color: "EEEEEE" },
          { content: "MEDIDA\nINTERNAS MM\n(L, A, AL)", background_color: "EEEEEE" },
          { content: "RESISTENCIA", background_color: "EEEEEE" },
          { content: "PAPEL", background_color: "EEEEEE" },
          { content: "ACABADOS", background_color: "EEEEEE" },
          { content: "CANTIDAD", background_color: "EEEEEE" },
          { content: "PRECIO", background_color: "EEEEEE" }
        ]
      ]

      # Get the main material
      main_material = @quote.quote_materials.find_by(is_main: true)
      processes = @quote.quote_processes.map { |qp| qp.manufacturing_process.name.upcase }.join(", ")

      # Add single row with main material info
      items << [
        @quote.product_name.upcase,
        @quote.internal_measures&.upcase || "N/A",
        main_material&.material&.specifications&.upcase || "N/A",
        main_material&.material&.description&.upcase || "N/A",
        processes,
        number_with_delimiter(@quote.product_quantity, delimiter: ","),
        number_to_currency(@quote.product_value_per_piece, unit: "$", precision: 2, delimiter: ",")
      ]

      # Add IVA NO INCLUIDO row
      items << [{ content: "IVA NO INCLUIDO", colspan: 7, align: :right }]

      pdf.table(items, width: pdf.bounds.width) do |t|
        t.cells.padding = 3
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
        t.cells.align = :center
        t.cells.size = 8
        
        # Update column widths to accommodate the combined column
        t.column_widths = {
          0 => 110,  # Producto
          1 => 65,   # Medidas
          2 => 65,   # Resistencia
          3 => 85,   # Papel
          4 => 300,  # Acabados (combined width of previous 4 columns)
          5 => 50,   # Cantidad
          6 => 65    # Precio
        }
      end

      pdf.move_down 15

      # Additional costs table
      costs = [
        [
          { content: "HERRAMENTALES", background_color: "EEEEEE" },
          { content: "PRECIO", background_color: "EEEEEE" }
        ]
      ]

      # Add each extra from the quote
      @quote.quote_extras.each do |extra|
        costs << [
          extra.extra.description.upcase,
          number_to_currency(extra.price, unit: "$", precision: 2, delimiter: ",")
        ]
      end

      pdf.table(costs, width: 280) do |t|
        t.cells.padding = 3
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
        t.cells.size = 8
        t.cells.align = :left  # Align text left in first column
        t.column(1).align = :right  # Align prices right in second column
        
        # Set specific column widths
        t.column_widths = {
          0 => 180,  # Herramentales column
          1 => 100   # Precio column
        }
      end

      pdf.move_down 15

      # Terms and conditions
      pdf.text "CONDICIONES DE VENTA", style: :bold, size: 8
      GeneralConfiguration.sale_conditions.each do |condition|
        pdf.text "• #{condition}", size: 8
      end

      pdf.move_down 15

      # Contact info with clickable email
      signature = GeneralConfiguration.signature_info
      if signature
        pdf.text signature.signature_name, style: :bold, size: 8
        pdf.fill_color "0000FF"
        pdf.text "CORREO: #{signature.signature_email}", 
                 size: 8, 
                 link: "mailto:#{signature.signature_email}"
        pdf.fill_color "000000"
        pdf.text "CEL/TEL: #{signature.signature_phone}  WHATSAPP: #{signature.signature_whatsapp}", size: 8
      end

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