require 'rails_helper'

RSpec.describe Conversion, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:source_currency_code) }
    it { is_expected.to validate_length_of(:source_currency_code).is_equal_to(3) }

    it { is_expected.to validate_presence_of(:target_currency_code) }
    it { is_expected.to validate_length_of(:target_currency_code).is_equal_to(3) }

    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:source_currency).class_name('Currency').with_foreign_key(:source_currency_code).with_primary_key(:code) }
    it { is_expected.to belong_to(:target_currency).class_name('Currency').with_foreign_key(:target_currency_code).with_primary_key(:code) }
  end
end
