require 'nokogiri'
require 'open-uri'
require 'httparty'
# require 'bigdecimal'   #TODO

module Currency
  class Request
    
    def first_request(valute_id)
      doc = Nokogiri::HTML(open("https://www.cbr.ru/scripts/xml_daily.asp"))
      rate_by_cbr = doc.css("[id='#{valute_id}']").children[4].text.to_f
    end

    def second_request(rate)
      @access_key = "662369652784e5f729de1b470b6a6c2a" #TODO
      url = "http://data.fixer.io/api/latest?access_key=#{@access_key}"
      response = HTTParty.get(url)
      rub = response.parsed_response["rates"]["RUB"]
      rate_by_fixer = response.parsed_response["rates"]["#{rate}"] * rub
    end

    def condition(item_1, item_2)
      item_1 < item_2 ? item_1 : item_2
    end
  end


  class Converter

    def amount(currency, quantity)
      currency * quantity
    end
    
  end

  class Result

    def difference(currency_first, currency_second)
      currency_first - currency_second
    end

    def in(difference, currency)
      difference * currency
    end
  
  end

end

currency = Currency::Request.new
dollar_rate_by_cbr = currency.first_request('R01235')
rubel_rate_by_cbr = currency.first_request('R01090B')

dollar_rate_by_fixer = currency.second_request("USD")
rubel_rate_by_fixer = currency.second_request("BYN")


favorit_rate_of_dollar = currency.condition(dollar_rate_by_fixer, dollar_rate_by_cbr)
favorit_rate_of_rubel = currency.condition(rubel_rate_by_fixer, rubel_rate_by_cbr)

converter = Currency::Converter.new
p usd = converter.amount(favorit_rate_of_dollar, 200)
p byn = converter.amount(favorit_rate_of_rubel, 1000)


result = Currency::Result.new
p diffe = result.difference(usd, byn)
p result.in(diffe, usd)
p result.in(diffe, byn)
