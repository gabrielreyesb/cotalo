class ApplicationController < ActionController::Base
    helper DeviseHelper
    before_action :authenticate_user!
    before_action :set_quote_info

    private

    def set_quote_info
        return unless current_user
        @latest_quote = current_user.quotes.last
        @quotes_total = current_user.quotes.sum(:total_quote_value)
        @quotes_count = current_user.quotes.count
        @recent_quotes = current_user.quotes.order(created_at: :desc).limit(10)
    end
end
