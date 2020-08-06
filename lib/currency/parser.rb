require 'nokogiri'
require 'open-uri'
require 'httparty'
# require 'bigdecimal'   #TODO

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
      rub = response.parsed_response["rates"]["RUB"]
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

  

end

currency = Currency::Request.new('R01235', "USD", "662369652784e5f729de1b470b6a6c2a")
currency.request_by_cbr
currency.request_by_fixer
p usd = currency.condition


currency = Currency::Request.new('R01090B', "BYN", "662369652784e5f729de1b470b6a6c2a")
currency.request_by_cbr
currency.request_by_fixer
p byn = currency.condition

converter = Currency::Converter.new
p usd_sum = converter.amount(usd, 200)
p byn_sum = converter.amount(byn, 1000)


