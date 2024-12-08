class ManufacturingProcessesController < ApplicationController
  before_action :set_manufacturing_process, only: %i[ show edit update destroy ]

  def index
    @manufacturing_processes = ManufacturingProcess.all
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
    @manufacturing_process = ManufacturingProcess.new
  end

  def edit
  end

  def create
    @manufacturing_process = ManufacturingProcess.new(manufacturing_process_params)

    respond_to do |format|
      if @manufacturing_process.save
        format.html { redirect_to manufacturing_process_url(@manufacturing_process), notice: "Manufacturing process was successfully created." }
        format.json { render :show, status: :created, location: @manufacturing_process }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @manufacturing_process.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @manufacturing_process.update(manufacturing_process_params)
        format.html { redirect_to manufacturing_process_url(@manufacturing_process), notice: "Manufacturing process was successfully updated." }
        format.json { render :show, status: :ok, location: @manufacturing_process }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @manufacturing_process.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @manufacturing_process.destroy!

    respond_to do |format|
      format.html { redirect_to manufacturing_processes_url, notice: "Manufacturing process was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_manufacturing_process
      @manufacturing_process = ManufacturingProcess.find(params[:id])
    end

    def manufacturing_process_params
      params.require(:manufacturing_process).permit(:description, :price, :unit_id, :name, :specifications, :comments, :maximum_length, :maximum_width, :minimum_length, :minimum_width)
    end
end
