class PagesController < ApplicationController
  before_action :authenticate_user!

    def index
    end
    
    def home
      @resource_name = :user
    end

    def send_quote
      customer_email = 'gabriel@handy.la'
      QuoteMailer.send_quote(customer_email).deliver_later 
      redirect_to root_path, notice: 'Quote sent successfully!'
    end
end