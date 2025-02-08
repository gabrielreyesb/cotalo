class MaterialsController < ApplicationController
  before_action :set_material, only: %i[ show edit update destroy ]

  # GET /materials or /materials.json
  def index
    @materials = current_user.materials.includes(:unit).order(:description)
  end

  # GET /materials/1 or /materials/1.json
  def show
    Rails.logger.debug "Material full inspect: #{@material.inspect}"
    Rails.logger.debug "Material attributes: #{@material.attributes}"
    Rails.logger.debug "Material comments: #{@material.comments.inspect}"
    
    respond_to do |format|
      format.html
      format.json { 
        render json: @material.as_json(
          only: [:id, :description, :width, :length, :price, :unit_id, :specifications, :name, :comments]
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
    Rails.logger.debug "Material full inspect: #{@material.inspect}"
    Rails.logger.debug "Material attributes: #{@material.attributes}"
    Rails.logger.debug "Material comments for edit: #{@material.comments.inspect}"
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
      params.require(:material).permit(
        :description,
        :price,
        :width,
        :length,
        :unit_id,
        :specifications,
        :name,
        :comments
      )
    end
end
