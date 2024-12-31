class PagesController < ApplicationController
  before_action :authenticate_user!

    def index
    end
    
    def home
      Rails.logger.info "====== Loading Home Page ======"
      @quotes = Quote.all.order(created_at: :desc)

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

      Rails.logger.info "Quotes found: #{@quotes.count}"
      Rails.logger.info "Quotes: #{@quotes.inspect}"
    end

    def send_quote
      customer_email = 'gabriel@handy.la'
      QuoteMailer.send_quote(customer_email).deliver_later 
      redirect_to root_path, notice: 'Quote sent successfully!'
    end
end