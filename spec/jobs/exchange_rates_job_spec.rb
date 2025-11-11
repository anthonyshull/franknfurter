require "rails_helper"

RSpec.describe ExchangeRatesJob do
  describe "#perform" do
    before do
      # Mock the HTTP response to return rates for all currencies except the base
      allow(Net::HTTP).to receive(:start) do |host, port, **options, &block|
        uri = URI("http://#{host}:#{port}")
        base_currency = nil

        # Create a mock HTTP object that will be yielded to the block
        mock_http = instance_double(Net::HTTP)

        allow(mock_http).to receive(:get) do |request_uri|
          base_currency = request_uri.match(/base=(\w+)/)[1]

          rates = Currency.where.not(code: base_currency).pluck(:code).each_with_object({}) do |code, hash|
            hash[code] = rand(0.5..2.0).round(4)
          end

          instance_double(Net::HTTPResponse, body: { "rates" => rates }.to_json)
        end

        block.call(mock_http)
      end
    end

    it "fetches exchange rates for all currencies" do
      currency_count = Currency.count

      expect {
        described_class.perform_now
      }.to change(ExchangeRate, :count)

      # Should make one request per currency
      expect(Net::HTTP).to have_received(:start).at_least(currency_count).times
    end

    it "skips currency pairs where right < left" do
      # Clear existing rates
      ExchangeRate.delete_all

      described_class.perform_now

      # All stored rates should be normalized (left < right)
      ExchangeRate.find_each do |rate|
        expect(rate.left_currency_code).to be < rate.right_currency_code
      end
    end

    it "is idempotent when run multiple times" do
      described_class.perform_now
      initial_count = ExchangeRate.count

      described_class.perform_now
      expect(ExchangeRate.count).to eq(initial_count)
    end
  end
end
