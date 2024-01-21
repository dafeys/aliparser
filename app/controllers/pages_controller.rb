class PagesController < ApplicationController
  def index
  end

  def parse_site
    @rate = Rails.cache.fetch('currency_rate', expires_in: 1.hours) do
      currency_service = CurrencyService.new
      currency_service.get_currency_rate_buy
    end

    service = PageParserService.new(params[:url], @rate)
    @data = service.call

    # puts "=" * 100
    # puts "#{@data[:title]}, #{@data[:seller]}, #{@data[:attributes]}, #{@data[:price]}"

    render :index
  end
end
