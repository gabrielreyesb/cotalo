class ToolingsController < ApplicationController
  before_action :set_tooling, only: %i[ show edit update destroy ]

  # GET /toolings or /toolings.json
  def index
    @toolings = Tooling.all
  end

  # GET /toolings/1 or /toolings/1.json
  def show
  end

  # GET /toolings/new
  def new
    @tooling = Tooling.new
  end

  # GET /toolings/1/edit
  def edit
  end

  # POST /toolings or /toolings.json
  def create
    @tooling = Tooling.new(tooling_params)

    respond_to do |format|
      if @tooling.save
        format.html { redirect_to tooling_url(@tooling), notice: "Tooling was successfully created." }
        format.json { render :show, status: :created, location: @tooling }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @tooling.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /toolings/1 or /toolings/1.json
  def update
    respond_to do |format|
      if @tooling.update(tooling_params)
        format.html { redirect_to tooling_url(@tooling), notice: "Tooling was successfully updated." }
        format.json { render :show, status: :ok, location: @tooling }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tooling.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /toolings/1 or /toolings/1.json
  def destroy
    @tooling.destroy!

    respond_to do |format|
      format.html { redirect_to toolings_url, notice: "Tooling was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tooling
      @tooling = Tooling.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def tooling_params
      params.require(:tooling).permit(:description, :price, :unit_id)
    end
end
