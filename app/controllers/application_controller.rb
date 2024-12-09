class ApplicationController < ActionController::Base
    helper DeviseHelper
    before_action :set_quote_info

    private

    def set_quote_info
        @latest_quote = Quote.last
        @quotes_total = Quote.sum(:total_quote_value)
        @quotes_count = Quote.count
        @recent_quotes = Quote.order(created_at: :desc).limit(10)
    end
end
