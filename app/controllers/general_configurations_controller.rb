class GeneralConfigurationsController < ApplicationController
  before_action :set_general_configuration, only: %i[ show edit update destroy ]

  def index
    @general_configurations = GeneralConfiguration.all
  end

  def show
  end

  def new
    @general_configuration = GeneralConfiguration.new
  end

  def edit
  end

  def create
    @general_configuration = GeneralConfiguration.new(general_configuration_params)

    respond_to do |format|
      if @general_configuration.save
        format.html { redirect_to general_configuration_url(@general_configuration), notice: "General configuration was successfully created." }
        format.json { render :show, status: :created, location: @general_configuration }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @general_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @general_configuration.update(general_configuration_params)
        format.html { redirect_to general_configuration_url(@general_configuration), notice: "General configuration was successfully updated." }
        format.json { render :show, status: :ok, location: @general_configuration }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @general_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @general_configuration.destroy!

    respond_to do |format|
      format.html { redirect_to general_configurations_url, notice: "General configuration was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_general_configuration
      @general_configuration = GeneralConfiguration.find(params[:id])
    end

    def general_configuration_params
      params.require(:general_configuration).permit(:description, :amount,  :unit_id)
    end
end
