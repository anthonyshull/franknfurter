require 'rails_helper'

RSpec.describe ExchangeRate, type: :model do
  let(:currencies) { Currency.order("RANDOM()").limit(2).pluck(:code).sort }

  describe "validations" do
    it { is_expected.to validate_presence_of(:left_currency_code) }
    it { is_expected.to validate_length_of(:left_currency_code).is_equal_to(3) }

    it { is_expected.to validate_presence_of(:right_currency_code) }
    it { is_expected.to validate_length_of(:right_currency_code).is_equal_to(3) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:rate) }
    it { is_expected.to validate_numericality_of(:rate).is_greater_than(0) }

    context "when currencies are the same" do
      subject(:rate) do
        described_class.new(
          left_currency_code: currencies.first,
          right_currency_code: currencies.first,
          date: Date.today,
          rate: FFaker::Number.decimal
        )
      end

      it "is not valid" do
        expect(rate).not_to be_valid
      end

      it "adds error message" do
        rate.valid?
        expect(rate.errors[:left]).to include("currency code must differ from right currency code")
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:left_currency).class_name('Currency').with_foreign_key(:left_currency_code).with_primary_key(:code) }
    it { is_expected.to belong_to(:right_currency).class_name('Currency').with_foreign_key(:right_currency_code).with_primary_key(:code) }
  end

  describe "normalization" do
    context "when left > right alphabetically" do
      subject(:rate) do
        described_class.new(
          left_currency_code: currencies.last,
          right_currency_code: currencies.first,
          date: Date.today,
          rate: initial_rate
        )
      end

      let(:initial_rate) { FFaker::Number.decimal }
      let(:inverted_rate) { 1.0 / initial_rate }

      before { rate.valid? }

      it "swaps to put left before right" do
        expect(rate.left_currency_code).to eq(currencies.first)
      end

      it "swaps right to be after left" do
        expect(rate.right_currency_code).to eq(currencies.last)
      end

      it "inverts the rate" do
        expect(rate.rate).to be_within(0.00001).of(inverted_rate)
      end
    end

    context "when already in correct order" do
      subject(:rate) do
        described_class.new(
          left_currency_code: currencies.first,
          right_currency_code: currencies.last,
          date: Date.today,
          rate: initial_rate
        )
      end

      let(:initial_rate) { FFaker::Number.decimal }

      before { rate.valid? }

      it "does not change left_currency_code" do
        expect(rate.left_currency_code).to eq(currencies.first)
      end

      it "does not change right_currency_code" do
        expect(rate.right_currency_code).to eq(currencies.last)
      end

      it "does not change rate" do
        expect(rate.rate).to eq(initial_rate)
      end
    end

    it "is valid after normalization" do
      rate = described_class.new(
        left_currency_code: currencies.last,
        right_currency_code: currencies.first,
        date: Date.today,
        rate: FFaker::Number.decimal
      )
      expect(rate).to be_valid
    end
  end
end
