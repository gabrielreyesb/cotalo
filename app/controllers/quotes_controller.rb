class QuotesController < ApplicationController
  def new
    @quote = Quote.new
    @quote.quote_processes.build 
    @quote.quote_toolings.build 
  end

  def create
    @quote = Quote.new(quote_params)

    if @quote.save
      redirect_to root_path, notice: "Cotización creada exitosamente." 
    else
      render :new, status: :unprocessable_entity 
    end
  end

  def calculate_quote
    respond_to do |format|
      format.html
      format.pdf do
        pdf = QuotePdf.new(@quote)
        send_data pdf.render, filename: "quote_#{@quote.id}.pdf", type: "application/pdf", disposition: "inline" 
      end
    end
  end

  private

  def quote_params
    params.require(:quote).permit(:width, :length, :pieces, :material_id, manufacturing_process_id, quote_processes_attributes: [:id, :process_id, :_destroy], quote_toolings_attributes: [:id, :tooling_id, :_destroy])
  end
end