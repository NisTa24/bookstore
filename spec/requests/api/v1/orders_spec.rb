require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  describe "GET /api/v1/orders" do
    before do
      Ordering::ReadModels::OrderSummary.create(
        order_id: "o1",
        order_number: "ORD-111",
        customer_email: "a@example.com",
        status: "confirmed",
        total_amount_cents: 1999,
        item_count: 1
      )
      Ordering::ReadModels::OrderSummary.create(
        order_id: "o2",
        order_number: "ORD-222",
        customer_email: "b@example.com",
        status: "pending",
        total_amount_cents: 2999,
        item_count: 2
      )
    end

    it "returns order summaries" do
      get "/api/v1/orders"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end
  end

  describe "GET /api/v1/orders/:id" do
    let!(:summary) do
      Ordering::ReadModels::OrderSummary.create(
        order_id: "o1",
        order_number: "ORD-111",
        customer_email: "test@example.com",
        status: "pending",
        total_amount_cents: 1999,
        item_count: 1
      )
    end

    it "returns the order summary" do
      get "/api/v1/orders/o1"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["order_number"]).to eq("ORD-111")
    end

    it "returns 404 for unknown order" do
      get "/api/v1/orders/nonexistent"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    let(:book_id) { SecureRandom.uuid }

    before do
      Pricing::Price.create(
        book_id: book_id,
        amount_cents: 1999,
        currency: "USD",
        effective_from: 1.day.ago
      )
    end

    it "creates an order and returns 201" do
      post "/api/v1/orders", params: {
        order: {
          customer_email: "buyer@example.com",
          items: [ { book_id: book_id, quantity: 2 } ]
        }
      }

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["order_number"]).to match(/\AORD-/)
      expect(json["total"]).to eq("39.98")
      expect(json["status"]).to eq("pending")
      expect(json["message"]).to eq("Order placed successfully")
    end

    it "creates an Order record" do
      expect {
        post "/api/v1/orders", params: {
          order: {
            customer_email: "buyer@example.com",
            items: [ { book_id: book_id, quantity: 1 } ]
          }
        }
      }.to change(Ordering::Order, :count).by(1)
    end

    it "returns 422 for invalid email" do
      post "/api/v1/orders", params: {
        order: {
          customer_email: "bad",
          items: [ { book_id: book_id, quantity: 1 } ]
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 when book has no price" do
      post "/api/v1/orders", params: {
        order: {
          customer_email: "buyer@example.com",
          items: [ { book_id: SecureRandom.uuid, quantity: 1 } ]
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/orders/:id" do
    let!(:order) do
      Ordering::Order.create(
        order_number: "ORD-CANCEL",
        customer_email: "test@example.com",
        status: "pending"
      )
    end

    it "cancels the order" do
      delete "/api/v1/orders/#{order.id}"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("cancelled")
      expect(order.reload.status).to eq("cancelled")
    end

    it "returns 422 for nonexistent order" do
      delete "/api/v1/orders/nonexistent"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
