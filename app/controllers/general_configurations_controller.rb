class GeneralConfigurationsController < ApplicationController
  before_action :set_general_configuration, only: [:show, :edit, :update, :destroy]

  def index
    @general_configurations = current_user.general_configurations.includes(:unit).order(:description)
  end

  def show
  end

  def new
    @general_configuration = current_user.general_configurations.build
  end

  def edit
  end

  def create
    @general_configuration = current_user.general_configurations.build(general_configuration_params)

    if @general_configuration.save
      redirect_to general_configurations_path, notice: 'General configuration was successfully created.'
    else
      render :new
    end
  end

  def update
    if @general_configuration.update(general_configuration_params)
      redirect_to general_configurations_path, notice: 'General configuration was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @general_configuration.destroy
    redirect_to general_configurations_url, notice: 'General configuration was successfully destroyed.'
  end

  private

  def set_general_configuration
    @general_configuration = current_user.general_configurations.find(params[:id])
  end

  def general_configuration_params
    params.require(:general_configuration).permit(:description, :amount, :unit_id)
  end
end
