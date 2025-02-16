class MultiQuotePdfGenerator
  include ActionView::Helpers::NumberHelper

  def initialize(quotes)
    @quotes = quotes
  end

  def generate
    Prawn::Document.new(
      page_size: "LETTER",
      page_layout: :landscape,
      margin: [40, 20, 40, 20]  # [top, right, bottom, left]
    ) do |pdf|
      # === Header Section ===
      logo_path = "#{Rails.root}/app/assets/images/logo.png"
      pdf.image logo_path, width: 120, position: :left if File.exist?(logo_path)
      
      pdf.text "Guadalajara, Jalisco. A #{Time.current.strftime('%d de %B').upcase} del #{Time.current.year}",
               align: :right, size: 9
      pdf.stroke_horizontal_rule
      pdf.move_down 15

      watermark_path = "#{Rails.root}/app/assets/images/box_watermark.png"
      if File.exist?(watermark_path)
        pdf.create_stamp("background") do
          pdf.image watermark_path, at: [300, 400], width: 400, opacity: 0.2
        end
        pdf.stamp("background")
      end

      # === Title ===
      pdf.text "Cotizaciones Seleccionadas", size: 18, style: :bold, align: :center
      pdf.move_down 20

      # === Customer Info Section ===
      # Using info from the first quote (assumes all quotes are for the same client)
      first_quote = @quotes.first
      customer_info = [
        ["CLIENTE:", first_quote.customer_name.to_s.upcase],
        ["EMPRESA:", (first_quote.customer_organization || "Sin organización").upcase],
        ["CORREO:", first_quote.customer_email.to_s],
        ["TELÉFONO:", first_quote.customer_phone.present? ? first_quote.customer_phone : "No especificado"],
        ["PROYECTO:", first_quote.projects_name.to_s.upcase]
      ]
      pdf.table(customer_info, width: 300, cell_style: { borders: [], padding: [2, 5], size: 9 }) do |t|
        t.cells.style { |c| c.font_style = c.column == 0 ? :bold : :normal }
      end
      pdf.move_down 10

      # === Main Table Section ===
      # Build a single table with one row per selected quote.
      # Columns: Fecha, Producto, Medidas, Resistencia, Papel, Acabados, Cantidad, Precio
      header = [
        { content: "FECHA", background_color: "EEEEEE" },
        { content: "PRODUCTO", background_color: "EEEEEE" },
        { content: "MEDIDA INTERNAS MM\n(L, A, AL)", background_color: "EEEEEE" },
        { content: "RESISTENCIA", background_color: "EEEEEE" },
        { content: "PAPEL", background_color: "EEEEEE" },
        { content: "ACABADOS", background_color: "EEEEEE" },
        { content: "CANTIDAD", background_color: "EEEEEE" },
        { content: "PRECIO", background_color: "EEEEEE" }
      ]
      table_data = []
      table_data << header

      @quotes.each do |quote|
        main_material = quote.quote_materials.find_by(is_main: true)
        processes = quote.quote_processes.map { |qp| qp.manufacturing_process.name.upcase }.join(", ")
        row = []
        row << quote.created_at.strftime("%d/%m/%Y")
        row << quote.product_name.to_s.upcase
        row << (quote.internal_measures&.upcase || "N/A")
        row << (main_material&.material&.specifications&.upcase || "N/A")
        row << (main_material&.material&.name&.upcase || "N/A")
        row << processes
        row << number_with_delimiter(quote.product_quantity, delimiter: ",")
        row << number_to_currency(quote.product_value_per_piece, unit: "$", precision: 2, delimiter: ",")
        table_data << row
      end

      # Add an extra row for IVA (if needed)
      table_data << [{ content: "IVA NO INCLUIDO", colspan: 8, align: :right }]

      pdf.table(table_data, width: pdf.bounds.width) do |t|
        t.cells.padding = 3
        t.cells.borders = [:bottom, :top, :left, :right]
        t.cells.border_width = 0.5
        t.cells.align = :center
        t.cells.size = 8
        t.column_widths = {
          0 => 60,   # Fecha
          1 => 110,  # Producto
          2 => 65,   # Medidas
          3 => 65,   # Resistencia
          4 => 85,   # Papel
          5 => 150,  # Acabados
          6 => 50,   # Cantidad
          7 => 65    # Precio
        }
      end

      pdf.move_down 15

      # === Sale Conditions Section ===
      sale_conditions_setting = AppSetting.find_by(user_id: first_quote.user_id, key: "sale_conditions")
      sale_conditions = sale_conditions_setting ? sale_conditions_setting.value : []
      pdf.text "CONDICIONES DE VENTA", style: :bold, size: 10
      sale_conditions.each do |condition|
        pdf.text "• #{condition}", size: 9
      end
      pdf.move_down 10

      # === Footer Section ===
      pdf.bounding_box([pdf.bounds.left, pdf.bounds.bottom + 40], width: pdf.bounds.width, height: 40) do
        signature = GeneralConfiguration.signature_info
        if signature
          pdf.text signature.signature_name, style: :bold, size: 8
          pdf.fill_color "0000FF"
          pdf.text "CORREO: #{signature.signature_email}", size: 8, link: "mailto:#{signature.signature_email}"
          pdf.fill_color "000000"
          pdf.text "CEL/TEL: #{signature.signature_phone}  WHATSAPP: #{signature.signature_whatsapp}", size: 8
        end

        signature_setting = AppSetting.find_by(user_id: first_quote.user_id, key: "signature_info")
        if signature_setting.present?
          signature_value = signature_setting.value
          signature_string = "#{signature_value['name']}, Correo: #{signature_value['email']}, Teléfono: #{signature_value['phone']}, Whatsapp: #{signature_value['whatsapp']}"
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

        footer_images = {
          bosques: "#{Rails.root}/app/assets/images/Bosques.png",
          fda: "#{Rails.root}/app/assets/images/FDA.jpg",
          qr: "#{Rails.root}/app/assets/images/qr-code.png"
        }
        x_position = pdf.bounds.width - 180
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