class ToolingsController < ApplicationController
  before_action :set_tooling, only: %i[ show edit update destroy ]

  # GET /toolings or /toolings.json
  def index
    @toolings = Tooling.all
  end

  # GET /toolings/1 or /toolings/1.json
  def show
  end

  # GET /toolings/new
  def new
    @tooling = Tooling.new
  end

  # GET /toolings/1/edit
  def edit
  end

  # POST /toolings or /toolings.json
  def create
    @tooling = Tooling.new(tooling_params)

    if @tooling.save
      redirect_to toolings_path, notice: 'Herramental creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /toolings/1 or /toolings/1.json
  def update
    if @tooling.update(tooling_params)
      redirect_to toolings_path, notice: 'Herramental actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /toolings/1 or /toolings/1.json
  def destroy
    @tooling.destroy!

    respond_to do |format|
      format.html { redirect_to toolings_url, notice: "Tooling was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tooling
      @tooling = Tooling.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tooling_params
      params.require(:tooling).permit(:description, :price, :unit_id)
    end
end
