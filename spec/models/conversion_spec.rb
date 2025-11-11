require 'rails_helper'

RSpec.describe Conversion, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:source_currency_code) }
    it { is_expected.to validate_length_of(:source_currency_code).is_equal_to(3) }

    it { is_expected.to validate_presence_of(:target_currency_code) }
    it { is_expected.to validate_length_of(:target_currency_code).is_equal_to(3) }

    it { is_expected.to validate_presence_of(:source_amount) }
    it { is_expected.to validate_numericality_of(:source_amount).is_greater_than(0) }

    it { is_expected.to validate_presence_of(:target_amount) }
    it { is_expected.to validate_numericality_of(:target_amount).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:source_currency).class_name('Currency') }
    it { is_expected.to belong_to(:target_currency).class_name('Currency') }
  end
end
