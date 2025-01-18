class UnitEquivalencesController < ApplicationController
  before_action :set_unit_equivalence, only: %i[ show edit update destroy ]

  # GET /unit_equivalences or /unit_equivalences.json
  def index
    @unit_equivalences = UnitEquivalence.all
  end

  # GET /unit_equivalences/1 or /unit_equivalences/1.json
  def show
  end

  # GET /unit_equivalences/new
  def new
    @unit_equivalence = UnitEquivalence.new
    @available_units = Unit.all
  end

  # GET /unit_equivalences/1/edit
  def edit
    @available_units = Unit.all
  end

  # POST /unit_equivalences or /unit_equivalences.json
  def create
    @unit_equivalence = UnitEquivalence.new(unit_equivalence_params)
    @available_units = Unit.all

    if @unit_equivalence.save
      redirect_to unit_equivalences_path, notice: "Equivalencia creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /unit_equivalences/1 or /unit_equivalences/1.json
  def update
    @available_units = Unit.all
    if @unit_equivalence.update(unit_equivalence_params)
      redirect_to unit_equivalences_path, notice: "Equivalencia actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /unit_equivalences/1 or /unit_equivalences/1.json
  def destroy
    @unit_equivalence.destroy!
    redirect_to unit_equivalences_path, status: :see_other, notice: "Equivalencia eliminada exitosamente."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit_equivalence
      @unit_equivalence = UnitEquivalence.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def unit_equivalence_params
      params.require(:unit_equivalence).permit(:unit_one_id, :unit_two_id, :conversion_factor)
    end
end
