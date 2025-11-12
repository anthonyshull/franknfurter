# Represents a currency used in exchange rates and conversions.
#
# This model uses the 3-character currency code (e.g., "USD", "MXN") as the primary key.
# Currencies cannot be deleted if they have associated exchange rates or conversions.
#
# @attr [String] code The 3-character ISO currency code (primary key)
class Currency < ApplicationRecord
  self.primary_key = :code

  # Exchange rates where this currency is the left (alphabetically first) currency
  has_many :exchange_rates_as_left,
           class_name: "ExchangeRate",
           foreign_key: :left_currency_code,
           dependent: :restrict_with_error

  # Exchange rates where this currency is the right (alphabetically second) currency
  has_many :exchange_rates_as_right,
           class_name: "ExchangeRate",
           foreign_key: :right_currency_code,
           dependent: :restrict_with_error

  # Conversions where this currency is the source currency
  has_many :conversions_as_source,
           class_name: "Conversion",
           foreign_key: :source_currency_code,
           dependent: :restrict_with_error

  # Conversions where this currency is the target currency
  has_many :conversions_as_target,
           class_name: "Conversion",
           foreign_key: :target_currency_code,
           dependent: :restrict_with_error

  validates :code, presence: true, length: { is: 3 }
end
