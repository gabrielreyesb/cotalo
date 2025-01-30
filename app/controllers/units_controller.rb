class UnitsController < ApplicationController
  before_action :set_unit, only: %i[ show edit update destroy ]

  # GET /units or /units.json
  def index
    @units = current_user.units.order(:description)
  end

  # GET /units/1 or /units/1.json
  def show
  end

  # GET /units/new
  def new
    @unit = current_user.units.build
  end

  # GET /units/1/edit
  def edit
  end

  # POST /units or /units.json
  def create
    @unit = current_user.units.build(unit_params)

    if @unit.save
      redirect_to units_path, notice: 'Unit was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /units/1 or /units/1.json
  def update
    if @unit.update(unit_params)
      redirect_to units_path, notice: 'Unit was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /units/1 or /units/1.json
  def destroy
    if @unit.destroy
      redirect_to units_url, notice: 'Unit was successfully destroyed.'
    else
      redirect_to units_url, alert: 'Unit cannot be deleted because it is being used.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = current_user.units.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_params
      params.require(:unit).permit(:description)
    end
end
