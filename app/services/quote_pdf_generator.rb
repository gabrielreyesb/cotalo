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
      
      # Get next quote number
      quote_number = PdfCounter.next_number
      
      # Add quote number and date in the same row
      pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width, height: 20) do
        pdf.text_box "Cotización: #{quote_number}", 
                    at: [pdf.bounds.width/2 - 50, pdf.bounds.top],
                    width: 100,
                    align: :center,
                    size: 12,
                    style: :bold
        pdf.text_box "Guadalajara, Jalisco. A #{Time.current.strftime('%d de %B').upcase} del #{Time.current.year}",
                    at: [pdf.bounds.width - 300, pdf.bounds.top],
                    width: 300,
                    align: :right,
                    size: 9
      end
      pdf.move_down 15
      pdf.stroke_horizontal_rule
      pdf.move_down 10

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
        main_material&.material&.name&.upcase || "N/A",
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

      # Insert Sale Conditions under Extras table using AppSetting
      sale_conditions_setting = AppSetting.find_by(user_id: @quote.user_id, key: "sale_conditions")
      sale_conditions = sale_conditions_setting ? sale_conditions_setting.value : []
      pdf.text "CONDICIONES DE VENTA", style: :bold, size: 10
      sale_conditions.each do |condition|
        pdf.text "• #{condition}", size: 9
      end
      pdf.move_down 10

      # Footer: repeat on all pages, placed at the bottom
      pdf.repeat(:all) do
        pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 40], width: pdf.bounds.width, height: 40) do

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

          signature_setting = AppSetting.find_by(user_id: @quote.user_id, key: "signature_info")
          if signature_setting.present?
            signature = signature_setting.value
            signature_string = "#{signature['name']}, Correo: #{signature['email']}, Teléfono: #{signature['phone']}, Whatsapp: #{signature['whatsapp']}"
            pdf.text signature_string, size: 9
          end

          pdf.stroke_horizontal_rule
          
          pdf.text_box "Fabricamos con materiales sustentables que protegen al medio ambiente...", 
                       at: [0, 20],
                       width: pdf.bounds.width - 200,
                       color: "008000",
                       align: :left,
                       style: :italic,
                       size: 8

          # Footer images
          footer_images = {
            bosques: "#{Rails.root}/app/assets/images/Bosques.png",
            fda: "#{Rails.root}/app/assets/images/FDA.jpg",
            qr: "#{Rails.root}/app/assets/images/qr-code.png"
          }
          x_position = pdf.bounds.width - 180
          # Place images with fixed width and adjusted y-positions
          footer_images.each do |key, path|
            if File.exist?(path)
              case key
              when :bosques
                pdf.image path, at: [x_position, 20], width: 40
              when :fda
                pdf.image path, at: [x_position + 60, 20], width: 40
              when :qr
                pdf.image path, at: [x_position + 120, 20], width: 40
              end
            end
          end
        end
      end
    end
  end
end 