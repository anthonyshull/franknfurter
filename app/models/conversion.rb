class Conversion < ApplicationRecord
  belongs_to :source_currency,
             class_name: "Currency",
             foreign_key: :source_currency_code,
             primary_key: :code

  belongs_to :target_currency,
             class_name: "Currency",
             foreign_key: :target_currency_code,
             primary_key: :code

  validates :source_currency_code, presence: true, length: { is: 3 }
  validates :target_currency_code, presence: true, length: { is: 3 }

  validates :amount, presence: true, numericality: { greater_than: 0 }
end
