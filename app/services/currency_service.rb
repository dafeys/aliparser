require 'rest-client'
require 'json'

class CurrencyService
  MONOBANK_API_URL = 'https://api.monobank.ua/bank/currency'

  def get_currency_rate_buy
    response = RestClient.get(MONOBANK_API_URL)
    json_response = JSON.parse(response.body)

    find_rate_buy(json_response)
  end

  private

  def find_rate_buy(json_response)
    rate_buy = nil

    json_response.each do |currency|
      if currency['currencyCodeA'] == 840 && currency['currencyCodeB'] == 980
        rate_buy = currency['rateBuy']
        break
      end
    end

    rate_buy
  end
end
