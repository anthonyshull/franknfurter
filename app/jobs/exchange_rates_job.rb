require "json"
require "net/http"

# Fetches exchange rates from the Frankfurter API and stores them in the database.
#
# This job runs on a recurring schedule to keep exchange rates up to date.
# It fetches rates from the Frankfurter API service using the first currency
# alphabetically as the base, then stores all rates in the database.
#
# The job is idempotent - running it multiple times for the same date will update
# existing records rather than creating duplicates.
#
# The job includes automatic retries for common failure scenarios:
# - Database deadlocks: 3 attempts with 5 second wait
# - HTTP errors: 3 attempts with 5 second wait
# - Other errors: 1 attempt with 15 second wait
#
# @example Run the job manually
#   ExchangeRatesJob.perform_now
class ExchangeRatesJob < ActiveJob::Base
  queue_as :default

  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on Net::HTTPError, wait: 5.seconds, attempts: 3
  retry_on StandardError, wait: 15.seconds, attempts: 1

  # Fetches and stores exchange rates for today.
  #
  # @return [void]
  def perform
    base_url = "http://#{ENV.fetch('FRANKFURTER_HOST', 'frankfurter')}:#{ENV.fetch('FRANKFURTER_PORT', '8080')}"
    date = Date.today

    # Load all currency codes once to avoid N+1 queries
    currency_codes = Currency.pluck(:code)

    currency_codes.each do |left_currency_code|
      uri = URI("#{base_url}/v1/#{date}?base=#{left_currency_code}")

      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)

      data["rates"].each do |right_currency_code, rate|
        # Skip if right currency is less than left (we'll fetch it when that currency is the base)
        next if right_currency_code < left_currency_code

        # Skip if right currency doesn't exist in our database
        next unless currency_codes.include?(right_currency_code)

        Rails.logger.info "Storing rate: #{left_currency_code} -> #{right_currency_code} = #{rate}"

        ActiveRecord::Base.transaction do
          exchange_rate = ExchangeRate.lock.find_or_initialize_by(
            left_currency_code: left_currency_code,
            right_currency_code: right_currency_code,
            date: date
          )

          exchange_rate.rate = rate
          exchange_rate.save!
        end
      end
    end
  end
end
