require "rails_helper"

RSpec.describe CurrenciesController, type: :controller do
  describe "GET #index" do
    before do
      allow(Currency).to receive_messages(order: Currency, pluck: [])
    end

    it "calls Currency.order(:code).pluck(:code)" do
      get :index

      expect(Currency).to have_received(:order).with(:code)
    end

    it "returns 200 status" do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end
end
