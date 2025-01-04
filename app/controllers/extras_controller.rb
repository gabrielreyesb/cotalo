class ExtrasController < ApplicationController
    before_action :set_extra, only: %i[ show edit update destroy ]

    # GET /extras or /extras.json
    def index
      @extras = Extra.all
    end
  
    # GET /extras/1 or /extras/1.json
    def show
    end
  
    # GET /extras/new
    def new
      @extra = Extra.new
    end
  
    # GET /extras/1/edit
    def edit
    end
  
    # POST /toolings or /toolings.json
    def create
      @extra = Extra.new(extra_params)
  
      if @extra.save
        redirect_to extras_path, notice: 'Extra creado exitosamente.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /toolings/1 or /toolings/1.json
    def update
      if @extra.update(extra_params)
        redirect_to extras_path, notice: 'Extra actualizado exitosamente.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    # DELETE /extras/1 or /extras/1.json
    def destroy
      @extra.destroy!
  
      respond_to do |format|
        format.html { redirect_to extras_url, notice: "Extra was successfully destroyed." }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_extra
        @extra = Extra.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def extra_params
        params.require(:extra).permit(:description, :price, :unit_id)
      end
end 