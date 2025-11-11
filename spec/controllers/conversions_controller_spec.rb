require "rails_helper"

RSpec.describe ConversionsController, type: :controller do
  describe "POST #create" do
    let(:exchange_rate) { build(:exchange_rate) }
    let(:params) do
      {
        source_currency_code: exchange_rate.left_currency_code,
        target_currency_code: exchange_rate.right_currency_code,
        amount: rand(1..1000)
      }
    end

    context "when conversion is successful" do
      let(:conversion) { instance_double(Conversion, save: true) }

      before do
        allow(ConversionsService).to receive(:convert).and_return(rand(1..1000))
        allow(Conversion).to receive(:new).and_return(conversion)
        allow(ConversionBlueprint).to receive(:render)
      end

      it "returns 201 status" do
        post :create, params: params

        expect(response).to have_http_status(:created)
      end

      it "calls ConversionsService" do
        post :create, params: params

        expect(ConversionsService).to have_received(:convert)
      end

      it "creates and saves a new Conversion" do
        post :create, params: params

        expect(Conversion).to have_received(:new)
        expect(conversion).to have_received(:save)
      end

      it "renders using ConversionBlueprint" do
        post :create, params: params

        expect(ConversionBlueprint).to have_received(:render)
      end
    end

    context "when conversion fails to save" do
      let(:conversion) { instance_double(Conversion, save: false, errors: instance_double(ActiveModel::Errors, full_messages: [])) }

      before do
        allow(ConversionsService).to receive(:convert).and_return(rand(1..1000))
        allow(Conversion).to receive(:new).and_return(conversion)
      end

      it "returns 422 status" do
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when ConversionsService returns nil" do
      before do
        allow(ConversionsService).to receive(:convert).and_return(nil)
      end

      it "returns 422 status" do
        post :create, params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when currency not found" do
      before do
        allow(ConversionsService).to receive(:convert).and_raise(ActiveRecord::RecordNotFound)
      end

      it "returns 404 status" do
        post :create, params: params

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET #index" do
    let(:conversions) { [ instance_double(Conversion), instance_double(Conversion) ] }
    let(:relation) { instance_double(ActiveRecord::Relation) }

    before do
      allow(Conversion).to receive(:order).and_return(relation)
      allow(relation).to receive(:limit).and_return(conversions)
      allow(ConversionBlueprint).to receive(:render)
    end

    it "returns 200 status" do
      get :index

      expect(response).to have_http_status(:ok)
    end

    it "queries for the 10 most recent conversions" do
      get :index

      expect(Conversion).to have_received(:order).with(created_at: :desc)
      expect(relation).to have_received(:limit).with(10)
    end

    it "renders conversions using ConversionBlueprint" do
      get :index

      expect(ConversionBlueprint).to have_received(:render).with(conversions)
    end
  end
end
