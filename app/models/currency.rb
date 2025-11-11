class Currency < ApplicationRecord
  self.primary_key = :code

  has_many :exchange_rates_as_left,
           class_name: "ExchangeRate",
           foreign_key: :left_currency_code,
           dependent: :restrict_with_error

  has_many :exchange_rates_as_right,
           class_name: "ExchangeRate",
           foreign_key: :right_currency_code,
           dependent: :restrict_with_error

  has_many :conversions_as_source,
           class_name: "Conversion",
           foreign_key: :source_currency_code,
           dependent: :restrict_with_error

  has_many :conversions_as_target,
           class_name: "Conversion",
           foreign_key: :target_currency_code,
           dependent: :restrict_with_error

  validates :code, presence: true, length: { is: 3 }
end
