class ManufacturingProcessesController < ApplicationController
  before_action :set_manufacturing_process, only: [:show, :edit, :update, :destroy]

  def index
    @manufacturing_processes = current_user.manufacturing_processes.includes(:unit).order(:name)
  end

  def show
    respond_to do |format|
      format.json { 
        render json: @manufacturing_process.as_json(include: :unit) 
      } 
    end
  end

  def new
    @manufacturing_process = current_user.manufacturing_processes.build
  end

  def edit
  end

  def create
    @manufacturing_process = current_user.manufacturing_processes.build(manufacturing_process_params)

    if @manufacturing_process.save
      redirect_to manufacturing_processes_path, notice: 'Manufacturing process was successfully created.'
    else
      render :new
    end
  end

  def update
    if @manufacturing_process.update(manufacturing_process_params)
      redirect_to manufacturing_processes_path, notice: 'Manufacturing process was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @manufacturing_process.destroy
    redirect_to manufacturing_processes_url, notice: 'Manufacturing process was successfully destroyed.'
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
    @manufacturing_process = current_user.manufacturing_processes.find(params[:id])
  end

  def manufacturing_process_params
    params.require(:manufacturing_process).permit(:name, :description, :price, :unit_id)
  end
end
