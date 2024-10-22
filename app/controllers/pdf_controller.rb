class PdfController < ApplicationController
  def generate
    pdf = Prawn::Document.new
    pdf.text "Hello, this is a PDF generated with Prawn!"
    # Add more content to the PDF as needed

    send_data pdf.render, filename: 'surtibox_document.pdf', type: 'application/pdf', disposition: 'inline'
  end
end