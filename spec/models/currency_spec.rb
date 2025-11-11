require 'rails_helper'

RSpec.describe Currency, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_length_of(:code).is_equal_to(3) }
  end

  describe "primary key" do
    it "uses code as the primary key" do
      random_code = FFaker::Lorem.characters(3).upcase
      currency = described_class.create!(code: random_code)

      expect(currency.id).to eq(random_code)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:exchange_rates_as_left) }
    it { is_expected.to have_many(:exchange_rates_as_right) }

    it { is_expected.to have_many(:conversions_as_source) }
    it { is_expected.to have_many(:conversions_as_target) }
  end
end
