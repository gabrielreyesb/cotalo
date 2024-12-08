class MaterialsController < ApplicationController
  before_action :set_material, only: %i[ show edit update destroy ]

  # GET /materials or /materials.json
  def index
    @materials = Material.all
  end

  # GET /materials/1 or /materials/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @material.as_json(only: [:id, :description, :width, :length, :price, :unit_id]) }
    end
  end

  # GET /materials/new
  def new
    @material = Material.new
  end

  # GET /materials/1/edit
  def edit
  end

  # POST /materials or /materials.json
  def create
    @material = Material.new(material_params)

    respond_to do |format|
      if @material.save
        format.html { redirect_to materials_path, notice: "Material was successfully created." } 
        format.json { render :show, status: :created, location: @material }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /materials/1 or /materials/1.json
  def update
    if @material.update(material_params)
      redirect_to materials_path, notice: 'Material actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /materials/1 or /materials/1.json
  def destroy
    @material.destroy!

    respond_to do |format|
      format.html { redirect_to materials_url, notice: "Material was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material
      @material = Material.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def material_params
      params.require(:material).permit(:description, :width, :length, :comments, :price, :unit_id)
    end
end
