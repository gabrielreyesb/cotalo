class PagesController < ApplicationController
  before_action :authenticate_user!

    def index
    end
    
    def home
      Rails.logger.debug "====== Loading Home Page ======"
      @quotes = current_user.quotes.order(created_at: :desc)

      # Apply date filters if present
      if params[:start_date].present?
        @quotes = @quotes.where("created_at >= ?", params[:start_date].to_date.beginning_of_day)
      end

      if params[:end_date].present?
        @quotes = @quotes.where("created_at <= ?", params[:end_date].to_date.end_of_day)
      end

      # Apply customer name filter if present
      if params[:customer_name].present?
        @quotes = @quotes.where("LOWER(customer_name) LIKE ?", "%#{params[:customer_name].downcase}%")
      end

      @quotes_count = @quotes.count
      Rails.logger.debug "Quotes found: #{@quotes_count}"
      @quotes = @quotes.limit(10)
      Rails.logger.debug "Quotes: #{@quotes.inspect}"
    end

    def send_quote
      @quote = current_user.quotes.find(params[:id])
      customer_email = 'gabriel@handy.la'
      QuoteMailer.send_quote(customer_email).deliver_later 
      redirect_to root_path, notice: 'Quote sent successfully!'
    end
end