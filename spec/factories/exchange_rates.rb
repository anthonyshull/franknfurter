FactoryBot.define do
  factory :exchange_rate do
    transient do
      currencies { Currency.order("RANDOM()").limit(2).pluck(:code).sort }
    end

    left_currency_code { currencies[0] }
    right_currency_code { currencies[1] }
    rate { rand(0.5..2.0).round(4) }
    date { Date.today }
  end
end
