# Represents a currency conversion request.
#
# Tracks conversion requests between two currencies with source and target amounts.
# Unlike ExchangeRate, conversions are directional (source -> target).
# An index on created_at enables efficient retrieval of recent conversions.
#
# @attr [String] source_currency_code The 3-character code of the source currency
# @attr [String] target_currency_code The 3-character code of the target currency
# @attr [Decimal] source_amount The amount in the source currency (must be greater than 0)
# @attr [Decimal] target_amount The converted amount in the target currency (must be greater than 0)
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

  validates :source_amount, presence: true, numericality: { greater_than: 0 }
  validates :target_amount, presence: true, numericality: { greater_than: 0 }
end
