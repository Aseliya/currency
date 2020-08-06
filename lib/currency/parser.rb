require 'nokogiri'
require 'open-uri'
require 'httparty'

module Currency
  class Request
    def initialize(valute_id, rate, access_key)
      @access_key = access_key
      @valute_id = valute_id
      @rate = rate
    end

    def request_by_cbr
      doc = Nokogiri::HTML(open("https://www.cbr.ru/scripts/xml_daily.asp"))
      @rate_by_cbr = doc.css("[id='#{@valute_id}']").children[4].text.to_f
    end

    def request_by_fixer
      url = "http://data.fixer.io/api/latest?access_key=#{@access_key}"
      response = HTTParty.get(url)
      rub = response.parsed_response["rates"]["RUB"] #cross rate by RUB
      @rate_by_fixer = response.parsed_response["rates"]["#{@rate}"] * rub
    end

    def condition
      @rate_by_cbr < @rate_by_fixer ? @rate_by_cbr : @rate_by_fixer
    end
  end


  class Converter
    def amount(currency, quantity)
      currency * quantity
    end
  end

  class Rate
    def initialize(first_currency, second_currency)
      @first_currency = first_currency
      @second_currency = second_currency
    end

    def in(currency_rate)
      (@first_currency - @second_currency) * currency_rate
    end
  end
  

end

currency_usd = Currency::Request.new('R01235', "USD", "662369652784e5f729de1b470b6a6c2a")
currency_usd.request_by_cbr
currency_usd.request_by_fixer
usd = currency_usd.condition


currency_byn = Currency::Request.new('R01090B', "BYN", "662369652784e5f729de1b470b6a6c2a")
currency_byn.request_by_cbr
currency_byn.request_by_fixer
byn = currency_byn.condition

converter = Currency::Converter.new
usd_sum = converter.amount(usd, 200)
byn_sum = converter.amount(byn, 1000)

result = Currency::Rate.new(usd_sum, byn_sum)
p result.in(usd).abs
p result.in(byn).abs
p "Результат расчета выведен по модулю"