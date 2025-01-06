class ManufacturingProcessesController < ApplicationController
  before_action :set_manufacturing_process, only: %i[ show edit update destroy ]

  def index
    @manufacturing_processes = ManufacturingProcess.order(:name)
  end

  class ManufacturingProcessesController < ApplicationController
    def show
      @manufacturing_process = ManufacturingProcess.find(params[:id])
  
      respond_to do |format|
        format.json { 
          render json: @manufacturing_process.as_json(include: :unit) 
        } 
      end
    end
  end

  def new
    @manufacturing_process = if params[:manufacturing_process]
      ManufacturingProcess.new(params[:manufacturing_process].permit!)
    else
      ManufacturingProcess.new
    end
  end

  def edit
  end

  def create
    @manufacturing_process = ManufacturingProcess.new(manufacturing_process_params)

    if @manufacturing_process.save
      redirect_to manufacturing_processes_path, notice: 'Proceso creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @manufacturing_process.update(manufacturing_process_params)
      redirect_to manufacturing_processes_path, notice: "Proceso actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @manufacturing_process.destroy!

    respond_to do |format|
      format.html { redirect_to manufacturing_processes_url, notice: "Manufacturing process was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def copy
    original_process = ManufacturingProcess.find(params[:id])
    copied_params = original_process.attributes.except('id', 'created_at', 'updated_at')
    copied_params['name'] = "Copia de #{original_process.name}"
    
    redirect_to new_manufacturing_process_path(manufacturing_process: copied_params), 
                notice: 'Complete los detalles del nuevo proceso'
  end

  private
    def set_manufacturing_process
      @manufacturing_process = ManufacturingProcess.find(params[:id])
    end

    def manufacturing_process_params
      params.require(:manufacturing_process).permit(:description, :price, :unit_id, :name, :specifications, :comments, :maximum_length, :maximum_width, :minimum_length, :minimum_width)
    end
end
