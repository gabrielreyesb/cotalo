class PagesController < ApplicationController
  before_action :authenticate_user!

    def index
    end
    
    def home
      if params[:show_papers]
        @papers = Paper.all 
      end
      @paper = Paper.new
      @resource_name = :user
    end
end