# Represents a currency conversion request.
#
# Tracks conversion requests between two currencies with an amount.
# Unlike ExchangeRate, conversions are directional (source -> target).
#
# @attr [String] source_currency_code The 3-character code of the source currency
# @attr [String] target_currency_code The 3-character code of the target currency
# @attr [Decimal] amount The amount to convert (must be greater than 0)
# @attr [DateTime] created_at When the conversion was created
# @attr [DateTime] updated_at When the conversion was last updated
class Conversion < ApplicationRecord
  # The currency being converted from
  belongs_to :source_currency,
             class_name: "Currency",
             foreign_key: :source_currency_code,
             primary_key: :code

  # The currency being converted to
  belongs_to :target_currency,
             class_name: "Currency",
             foreign_key: :target_currency_code,
             primary_key: :code

  validates :source_currency_code, presence: true, length: { is: 3 }
  validates :target_currency_code, presence: true, length: { is: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
