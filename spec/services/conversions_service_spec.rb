require "rails_helper"

RSpec.describe ConversionsService do
  describe ".convert" do
    let!(:exchange_rate) { create(:exchange_rate) }
    let(:amount) { 100 }

    context "when converting between valid currencies" do
      it "converts from source to target correctly" do
        result = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount
        )

        expect(result).to eq((amount * exchange_rate.rate).round(2))
      end

      it "converts from target to source correctly (inverse)" do
        result = described_class.convert(
          source_currency_code: exchange_rate.right_currency_code,
          target_currency_code: exchange_rate.left_currency_code,
          amount: amount
        )

        expect(result).to eq((amount / exchange_rate.rate).round(2))
      end
    end

    context "when currency code does not exist" do
      it "returns nil for invalid source currency" do
        result = described_class.convert(
          source_currency_code: "XYZ",
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount
        )

        expect(result).to be_nil
      end

      it "returns nil for invalid target currency" do
        result = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: "XYZ",
          amount: amount
        )

        expect(result).to be_nil
      end

      it "returns nil when no exchange rate exists for the date" do
        result = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount,
          date: Date.today - 1.year
        )

        expect(result).to be_nil
      end
    end

    context "caching behavior" do
      it "caches exchange rate lookups" do
        # First call - should hit database and cache the result
        result1 = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount
        )

        # Second call - should use cache, not hit database
        expect(ExchangeRate).not_to receive(:rate_for)

        result2 = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount
        )

        expect(result1).to eq(result2)
      end

      it "uses separate cache keys for different currency pairs" do
        other_rate = create(:exchange_rate)

        # These should each hit the database once
        expect(ExchangeRate).to receive(:rate_for).twice.and_call_original

        result1 = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount
        )

        result2 = described_class.convert(
          source_currency_code: other_rate.left_currency_code,
          target_currency_code: other_rate.right_currency_code,
          amount: amount
        )

        expect(result1).not_to be_nil
        expect(result2).not_to be_nil
      end

      it "uses separate cache keys for different dates" do
        # Create rate for different date
        other_date = Date.today + 1.day
        create(:exchange_rate,
          left_currency_code: exchange_rate.left_currency_code,
          right_currency_code: exchange_rate.right_currency_code,
          rate: exchange_rate.rate * 1.1,
          date: other_date)

        # Should hit database for each different date
        expect(ExchangeRate).to receive(:rate_for).twice.and_call_original

        result1 = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount
        )

        result2 = described_class.convert(
          source_currency_code: exchange_rate.left_currency_code,
          target_currency_code: exchange_rate.right_currency_code,
          amount: amount,
          date: other_date
        )

        expect(result1).not_to eq(result2)
      end
    end
  end
end
