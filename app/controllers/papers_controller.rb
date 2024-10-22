class PapersController < ApplicationController
  before_action :set_paper, only: %i[ show edit update destroy ]

  def index
    @papers = Paper.all
  end

  def show
    @papers = Paper.all
  end

  def new
    @paper = Paper.new
  end

  def edit
    @paper = Paper.find(params[:id])
  end

  def create
    @paper = Paper.new(paper_params)

    respond_to do |format|
      if @paper.save
        format.html { redirect_to papers_path, notice: "Paper was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @paper.update(paper_params)
        format.html { redirect_to papers_path, notice: "Paper was successfully updated." }
        format.json { render :show, status: :ok, location: @paper }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @paper.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @paper.destroy!

    respond_to do |format|
      format.html { redirect_to papers_url, notice: "Paper was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_paper
      @paper = Paper.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def paper_params
      params.require(:paper).permit(:description, :size, :weight)
    end
end
