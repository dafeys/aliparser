class PagesController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def parse_site
    @rate = Rails.cache.fetch('currency_rate', expires_in: 1.hours) do
      currency_service = CurrencyService.new
      currency_service.get_currency_rate_buy
    end

    service = PageParserService.new(params[:url], @rate)
    @data = service.call

    if @data
      render turbo_stream: turbo_stream.replace(:parsed_data, partial: 'pages/parsed_data', locals: { data: @data })
    else
      render turbo_stream: turbo_stream.replace(:parsed_data, "No data available")
    end
  end

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to new_user_session_path, alert: 'Please sign in to continue'
    end
  end
end
