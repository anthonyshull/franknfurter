# Represents an exchange rate between two currencies on a specific date.
#
# Exchange rates are stored in normalized form where left_currency_code < right_currency_code
# alphabetically. The rate represents: 1 left_currency = rate * right_currency.
#
# When creating an exchange rate, you can provide currencies in any order. The before_validation
# callback will automatically swap them and invert the rate if needed to maintain alphabetical order.
#
# @example Create a rate (will be normalized automatically)
#   ExchangeRate.create!(
#     left_currency_code: "MXN",
#     right_currency_code: "USD",
#     date: Date.today,
#     rate: 0.05
#   )
#   # If USD > MXN alphabetically, it will swap to MXN/USD and invert the rate
#
# @attr [String] left_currency_code The alphabetically first currency code (3 characters)
# @attr [String] right_currency_code The alphabetically second currency code (3 characters)
# @attr [Date] date The date for this exchange rate
# @attr [Decimal] rate The exchange rate (1 left_currency = rate * right_currency)
class ExchangeRate < ApplicationRecord
  # The alphabetically first currency in the pair
  belongs_to :left_currency,
             class_name: "Currency",
             foreign_key: :left_currency_code,
             primary_key: :code

  # The alphabetically second currency in the pair
  belongs_to :right_currency,
             class_name: "Currency",
             foreign_key: :right_currency_code,
             primary_key: :code

  validates :left_currency_code, presence: true, length: { is: 3 }
  validates :right_currency_code, presence: true, length: { is: 3 }
  validates :date, presence: true
  validates :rate, presence: true, numericality: { greater_than: 0 }

  validate :left_before_right
  validate :currencies_differ

  before_validation :normalize_currency_order

  # Finds the exchange rate for a directional currency conversion.
  #
  # This method handles the lookup and rate inversion automatically, so callers
  # don't need to know about the internal normalization. It looks up the rate
  # using the normalized (alphabetically sorted) currency codes and inverts
  # the rate if needed based on the requested direction.
  #
  # @param source_currency_code [String] The source currency code
  # @param target_currency_code [String] The target currency code
  # @param date [Date] The date for the exchange rate
  # @return [Numeric, nil] The exchange rate from source to target, or nil if not found
  #
  # @example Get rate for MXN -> USD
  #   ExchangeRate.rate_for(source_currency_code: "MXN", target_currency_code: "USD", date: Date.today)
  #   # => 0.05 (for example)
  #
  # @example Get rate for USD -> MXN (automatically inverts)
  #   ExchangeRate.rate_for(source_currency_code: "USD", target_currency_code: "MXN", date: Date.today)
  #   # => 20.0 (inverse of 0.05)
  def self.rate_for(source_currency_code:, target_currency_code:, date:)
    currencies = [ source_currency_code, target_currency_code ].sort

    exchange_rate = find_by(
      left_currency_code: currencies.first,
      right_currency_code: currencies.last,
      date: date
    )

    return nil unless exchange_rate

    # The rate in DB represents: 1 left_currency = rate * right_currency
    # If source is left, use rate directly; if source is right, invert it
    if source_currency_code == exchange_rate.left_currency_code
      exchange_rate.rate
    else
      1.0 / exchange_rate.rate
    end
  end

  private

  # Normalizes the currency order to ensure left < right alphabetically.
  # Swaps currencies and inverts the rate if needed.
  def normalize_currency_order
    return unless currencies_set?

    if left_before_right?
      self.left_currency_code, self.right_currency_code = right_currency_code, left_currency_code

      self.rate = 1.0 / rate if rate.present? && rate != 0
    end
  end

  # Validates that left_currency_code < right_currency_code alphabetically.
  def left_before_right
    return unless currencies_set?

    if left_currency_code >= right_currency_code
      errors.add(:left, "currency code must be less than right currency code")
    end
  end

  # Validates that the two currencies are different.
  def currencies_differ
    return unless currencies_set?

    if left_currency_code == right_currency_code
      errors.add(:left, "currency code must differ from right currency code")
    end
  end

  # Checks if left currency should be after right currency alphabetically.
  # @return [Boolean] true if left > right alphabetically
  def left_before_right?
    return false unless currencies_set?

    left_currency_code > right_currency_code
  end

  # Checks if both currency codes are present.
  # @return [Boolean] true if both currency codes are set
  def currencies_set?
    left_currency_code.present? && right_currency_code.present?
  end
end
