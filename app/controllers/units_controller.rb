class UnitsController < ApplicationController
  before_action :set_unit, only: %i[ show edit update destroy ]

  # GET /units or /units.json
  def index
    @units = Unit.order(:description)
  end

  # GET /units/1 or /units/1.json
  def show
  end

  # GET /units/new
  def new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units or /units.json
  def create
    @unit = Unit.new(unit_params)

    respond_to do |format|
      if @unit.save
        format.html { redirect_to units_url, notice: "Unit was successfully created." }
        format.json { render :show, status: :created, location: @unit }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /units/1 or /units/1.json
  def update
    if @unit.update(unit_params)
      redirect_to units_path, notice: 'Unidad actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /units/1 or /units/1.json
  def destroy
    @unit.destroy!

    respond_to do |format|
      format.html { redirect_to units_url, notice: "Unit was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = Unit.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_params
      params.require(:unit).permit(:description)
    end
end
