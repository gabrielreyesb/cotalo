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

  private

  def quote_params
    params.require(:quote).permit(:width, :length, :pieces, :material_id, manufacturing_process_id, quote_processes_attributes: [:id, :process_id, :_destroy], quote_toolings_attributes: [:id, :tooling_id, :_destroy])
  end
end