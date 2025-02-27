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
      @extra = if params[:extra]
                current_user.extras.build(copy_extra_params)
              else
                current_user.extras.build
              end
    end
  
    # GET /extras/1/edit
    def edit
    end
  
    # POST /toolings or /toolings.json
    def create
      @extra = current_user.extras.build(extra_params)
  
      if @extra.save
        redirect_to extras_path
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /toolings/1 or /toolings/1.json
    def update
      if @extra.update(extra_params)
        redirect_to extras_path
      else
        render :edit, status: :unprocessable_entity
      end
    end
  
    # DELETE /extras/1 or /extras/1.json
    def destroy
      @extra.destroy!
      redirect_to extras_path
    end
  
    def copy
      original_extra = current_user.extras.find(params[:id])
      copied_params = original_extra.attributes.except('id', 'created_at', 'updated_at', 'user_id')
      copied_params['description'] = "Copia de #{original_extra.description}"
      
      @extra = current_user.extras.build(copied_params)
      render :new
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

      def copy_extra_params
        params.require(:extra).permit(:description, :price, :unit_id, :comments)
      end
end 