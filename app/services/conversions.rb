module Services
  class Conversions
    class << self
      def convert(source_currency:, target_currency:, amount:, date: Date.today)
        rate = load_exchange_rate(source_currency, target_currency, date)

        (amount * rate).round(2)
      end

      private

      def load_exchange_rate(source_currency, target_currency, date)
        cache_key = "db/exchange_rate/#{source_currency}/#{target_currency}/#{date}"

        Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          Rails.logger.info "Cache miss on #{cache_key}"

          find_exchange_rate(source_currency, target_currency, date)
        end
      end

      def find_exchange_rate(source_currency, target_currency, date)
        currencies = [ source_currency, target_currency ].sort

        exchange_rate = ExchangeRate.find_by(
          left_currency_code: currencies.first,
          right_currency_code: currencies.last,
          date: date
        )

        return nil unless exchange_rate

        # If the rate is stored in the order we need, use it directly
        # Otherwise, invert it
        if source_currency == exchange_rate.left_currency_code
          exchange_rate.rate
        else
          1.0 / exchange_rate.rate
        end
      end
    end
  end
end
