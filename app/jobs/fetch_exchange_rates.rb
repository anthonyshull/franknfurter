require "json"
require "net/http"

class FetchExchangeRates < ActiveJob::Base
  queue_as :default

  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on Net::HTTPError, wait: 5.seconds, attempts: 3
  retry_on StandardError, wait: 15.seconds, attempts: 1

  def perform(date: Date.today)
    base_url = "http://#{ENV['FRANKFURTER_HOST']}:#{ENV['FRANKFURTER_PORT']}"
    left_currency_code = Currency.order(:code).limit(1).pluck(:code).first

    uri = URI("#{base_url}/v1/#{date}?base=#{left_currency_code}")

    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    data["rates"].each do |right_currency_code, rate|
      Rails.logger.info "Storing rate: #{left_currency_code} -> #{right_currency_code} = #{rate}"

      ExchangeRate.find_or_create_by(
        left_currency_code: left_currency_code,
        right_currency_code: right_currency_code,
        date: date
      ) do |exchange_rate|
        exchange_rate.rate = rate
      end
    end
  end
end
