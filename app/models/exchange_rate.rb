class ExchangeRate < ApplicationRecord
  belongs_to :left_currency,
             class_name: "Currency",
             foreign_key: :left_currency_code,
             primary_key: :code

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

  private

  def normalize_currency_order
    return unless currencies_set?

    if left_before_right?
      self.left_currency_code, self.right_currency_code = right_currency_code, left_currency_code

      self.rate = 1.0 / rate if rate.present? && rate != 0
    end
  end

  def left_before_right
    return unless currencies_set?

    if left_currency_code >= right_currency_code
      errors.add(:left, "currency code must be less than right currency code")
    end
  end

  def currencies_differ
    return unless currencies_set?

    if left_currency_code == right_currency_code
      errors.add(:left, "currency code must differ from right currency code")
    end
  end

  def left_before_right?
    return false unless currencies_set?

    left_currency_code > right_currency_code
  end

  def currencies_set?
    left_currency_code.present? && right_currency_code.present?
  end
end
