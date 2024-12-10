class PagesController < ApplicationController
  before_action :authenticate_user!

    def index
    end
    
    def home
      Rails.logger.info "====== Loading Home Page ======"
      @recent_quotes = Quote.order(created_at: :desc).limit(5)
      Rails.logger.info "Quotes found: #{@recent_quotes.count}"
      Rails.logger.info "Quotes: #{@recent_quotes.inspect}"
    end

    def send_quote
      customer_email = 'gabriel@handy.la'
      QuoteMailer.send_quote(customer_email).deliver_later 
      redirect_to root_path, notice: 'Quote sent successfully!'
    end
end