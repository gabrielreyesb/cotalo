class MaterialsController < ApplicationController
  before_action :set_material, only: %i[ show edit update destroy ]

  # GET /materials or /materials.json
  def index
    @materials = current_user.materials.includes(:unit).order(:description)
  end

  # GET /materials/1 or /materials/1.json
  def show
    @material = Material.find(params[:id])
    
    respond_to do |format|
      format.html
      format.json { 
        render json: @material.as_json(
          only: [:id, :description, :width, :length, :price, :unit_id]
        ) 
      }
    end
  end

  # GET /materials/new
  def new
    @material = current_user.materials.build
  end

  # GET /materials/1/edit
  def edit
  end

  # POST /materials or /materials.json
  def create
    @material = current_user.materials.build(material_params)

    if @material.save
      redirect_to materials_path, notice: 'Material was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /materials/1 or /materials/1.json
  def update
    if @material.update(material_params)
      redirect_to materials_path, notice: 'Material was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /materials/1 or /materials/1.json
  def destroy
    @material.destroy
    redirect_to materials_url, notice: 'Material was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material
      @material = current_user.materials.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def material_params
      params.require(:material).permit(:description, :width, :length, :comments, :price, :unit_id)
    end
end
