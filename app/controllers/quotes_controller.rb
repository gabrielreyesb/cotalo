class QuotesController < ApplicationController
  def new
    @quote = Quote.new
    @quote.quote_processes.build 
    @quote.quote_toolings.build 

    respond_to do |format|
      format.html { render 'new' } # For regular HTML requests
      format.turbo_stream { render turbo_stream: turbo_stream.replace('main-content', partial: 'quotes/simple_form', locals: { quote: @quote }) }
    end
  end

  def create
    @quote = Quote.new(quote_params)
    if @quote.save
      # Handle successful save (e.g., redirect or render)
    else
      # Handle failure (e.g., render 'new' again)
    end
  end

  private

  def quote_params
    params.require(:quote).permit(
      :width, :length, :pieces, :material_id,
      :manufacturing_process_id,
      quote_processes_attributes: [:id, :process_id, :_destroy],
      quote_toolings_attributes: [:id, :tooling_id, :quantity, :_destroy]
    )
  end
end