# Service for converting amounts between currencies using stored exchange rates.
#
# This service looks up exchange rates from the database (with caching) and performs
# currency conversions. It handles bidirectional conversions by inverting rates when needed.
#
# @example Convert 100 USD to EUR
#   ConversionsService.convert(
#     source_currency_code: 'USD',
#     target_currency_code: 'EUR',
#     amount: 100
#   )
#   # => 85.00 (or whatever the current rate converts to)
class ConversionsService
  class << self
    # Converts an amount from one currency to another.
    #
    # @param source_currency_code [String] The 3-character code of the source currency
    # @param target_currency_code [String] The 3-character code of the target currency
    # @param amount [Numeric] The amount to convert
    # @param date [Date] The date to use for the exchange rate (defaults to today)
    # @return [BigDecimal] The converted amount rounded to 2 decimal places
    # @return [nil] If no exchange rate is found for the given date
    #
    # @example Convert with a specific date
    #   ConversionsService.convert(
    #     source_currency_code: 'GBP',
    #     target_currency_code: 'JPY',
    #     amount: 50,
    #     date: Date.new(2025, 1, 1)
    #   )
    def convert(source_currency_code:, target_currency_code:, amount:, date: Date.today)
      rate = load_exchange_rate(source_currency_code, target_currency_code, date)

      return nil if rate.nil?

      (BigDecimal(amount.to_s) * BigDecimal(rate.to_s)).round(2)
    end

    private

    # Loads an exchange rate from cache or database.
    # Cache expires after 1 hour with race condition protection.
    #
    # @param source_currency_code [String] The source currency code
    # @param target_currency_code [String] The target currency code
    # @param date [Date] The date for the exchange rate
    # @return [Float, nil] The exchange rate or nil if not found
    def load_exchange_rate(source_currency_code, target_currency_code, date)
      cache_key = "db/exchange_rate/#{source_currency_code}/#{target_currency_code}/#{date}"

      Rails.cache.fetch(cache_key, expires_in: 1.hour, race_condition_ttl: 10.seconds) do
        Rails.logger.info "Cache miss on #{cache_key}"

        ExchangeRate.rate_for(
          source_currency_code: source_currency_code,
          target_currency_code: target_currency_code,
          date: date
        )
      end
    end
  end
end
