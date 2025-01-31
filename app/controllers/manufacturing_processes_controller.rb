class ManufacturingProcessesController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_manufacturing_process, only: [:show, :edit, :update, :destroy]

  def index
    @manufacturing_processes = current_user.manufacturing_processes.includes(:unit).order(:name)
  end

  def show
    respond_to do |format|
      format.html
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
    
    Rails.logger.debug "Attempting to save manufacturing process with params: #{manufacturing_process_params.inspect}"

    respond_to do |format|
      if @manufacturing_process.save
        Rails.logger.debug "Successfully saved manufacturing process"
        format.html { redirect_to manufacturing_processes_path, notice: 'Manufacturing process was successfully created.' }
        format.turbo_stream { redirect_to manufacturing_processes_path, notice: 'Manufacturing process was successfully created.' }
      else
        Rails.logger.debug "Failed to save manufacturing process. Errors: #{@manufacturing_process.errors.full_messages}"
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.replace(
            'new_manufacturing_process_form',
            partial: 'form',
            locals: { manufacturing_process: @manufacturing_process }
          )
        }
      end
    end
  end

  def update
    respond_to do |format|
      if @manufacturing_process.update(manufacturing_process_params)
        format.html { redirect_to manufacturing_processes_path, notice: 'Manufacturing process was successfully updated.' }
        format.turbo_stream { redirect_to manufacturing_processes_path, notice: 'Manufacturing process was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { 
          render turbo_stream: turbo_stream.update(
            dom_id(@manufacturing_process, :form),
            partial: 'form',
            locals: { manufacturing_process: @manufacturing_process }
          )
        }
      end
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
    params.require(:manufacturing_process).permit(
      :name, 
      :description, 
      :price, 
      :unit_id,
      :specifications,
      :comments,
      :maximum_width,
      :maximum_length,
      :minimum_width,
      :minimum_length
    )
  end
end
