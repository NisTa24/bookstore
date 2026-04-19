require "rails_helper"

RSpec.describe "Api::V1::Prices", type: :request do
  let(:book_id) { SecureRandom.uuid }

  describe "GET /api/v1/prices/:book_id" do
    context "when a current price exists" do
      before do
        Pricing::Price.create(
          book_id: book_id,
          amount_cents: 1999,
          currency: "USD",
          effective_from: 1.day.ago
        )
      end

      it "returns the current price" do
        get "/api/v1/prices/#{book_id}"
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["book_id"]).to eq(book_id)
        expect(json["amount"]).to eq("19.99")
        expect(json["currency"]).to eq("USD")
      end
    end

    context "when no current price exists" do
      it "returns 404" do
        get "/api/v1/prices/#{book_id}"
        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["errors"]).to include("No current price found")
      end
    end
  end

  describe "POST /api/v1/prices" do
    it "sets a price and returns 201" do
      post "/api/v1/prices", params: {
        price: { book_id: book_id, amount_cents: 2999, currency: "USD" }
      }
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["book_id"]).to eq(book_id)
      expect(json["amount"]).to eq("29.99")
      expect(json["currency"]).to eq("USD")
      expect(json["message"]).to eq("Price set")
    end

    it "creates a Price record" do
      expect {
        post "/api/v1/prices", params: {
          price: { book_id: book_id, amount_cents: 2999 }
        }
      }.to change(Pricing::Price, :count).by(1)
    end

    it "returns 422 for negative amount" do
      post "/api/v1/prices", params: {
        price: { book_id: book_id, amount_cents: -100 }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
