class ExtrasController < ApplicationController
    before_action :set_extra, only: %i[ show edit update destroy ]

    # GET /extras or /extras.json
    def index
      @extras = current_user.extras.includes(:unit).order(:description)
    end
  
    # GET /extras/1 or /extras/1.json
    def show
    end
  
    # GET /extras/new
    def new
      @extra = current_user.extras.build
    end
  
    # GET /extras/1/edit
    def edit
    end
  
    # POST /toolings or /toolings.json
    def create
      @extra = current_user.extras.build(extra_params)
  
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
      redirect_to extras_path, notice: "Extra eliminado exitosamente."
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_extra
        @extra = current_user.extras.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def extra_params
        params.require(:extra).permit(:description, :price, :unit_id, :comments)
      end
end 