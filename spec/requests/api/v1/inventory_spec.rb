require "rails_helper"

RSpec.describe "Api::V1::Inventory", type: :request do
  let(:book_id) { SecureRandom.uuid }

  describe "GET /api/v1/inventory/:book_id" do
    context "when stock exists" do
      before do
        Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 20, quantity_reserved: 5)
      end

      it "returns stock levels" do
        get "/api/v1/inventory/#{book_id}"
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["book_id"]).to eq(book_id)
        expect(json["on_hand"]).to eq(20)
        expect(json["reserved"]).to eq(5)
        expect(json["available"]).to eq(15)
      end
    end

    context "when stock does not exist" do
      it "returns 404" do
        get "/api/v1/inventory/#{book_id}"
        expect(response).to have_http_status(:not_found)

        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Stock record not found")
      end
    end
  end

  describe "POST /api/v1/inventory" do
    it "registers stock and returns 201" do
      post "/api/v1/inventory", params: { stock: { book_id: book_id, quantity: 25 } }
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["book_id"]).to eq(book_id)
      expect(json["quantity_added"]).to eq(25)
      expect(json["new_total"]).to eq(25)
      expect(json["message"]).to eq("Stock registered")
    end

    it "creates a StockItem record" do
      expect {
        post "/api/v1/inventory", params: { stock: { book_id: book_id, quantity: 10 } }
      }.to change(Inventory::StockItem, :count).by(1)
    end

    it "adds to existing stock" do
      Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 10)

      post "/api/v1/inventory", params: { stock: { book_id: book_id, quantity: 5 } }
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["new_total"]).to eq(15)
    end

    it "returns 422 for invalid quantity" do
      post "/api/v1/inventory", params: { stock: { book_id: book_id, quantity: 0 } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
