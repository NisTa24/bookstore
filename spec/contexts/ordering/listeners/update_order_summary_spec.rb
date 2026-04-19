require "rails_helper"

RSpec.describe Ordering::Listeners::UpdateOrderSummary do
  subject(:listener) { described_class.new }

  describe "#order_placed" do
    it "creates an OrderSummary read model" do
      event = Ordering::Events::OrderPlaced.new(
        order_id: "o1",
        order_number: "ORD-ABC",
        customer_email: "test@example.com",
        line_items: [ { book_id: "b1", quantity: 2 }, { book_id: "b2", quantity: 1 } ],
        total_amount_cents: 2999,
        currency: "USD"
      )

      expect { listener.order_placed(event) }
        .to change(Ordering::ReadModels::OrderSummary, :count).by(1)

      summary = Ordering::ReadModels::OrderSummary.find_by(order_id: "o1")
      expect(summary.order_number).to eq("ORD-ABC")
      expect(summary.customer_email).to eq("test@example.com")
      expect(summary.status).to eq("pending")
      expect(summary.total_amount_cents).to eq(2999)
      expect(summary.item_count).to eq(2)
    end
  end

  describe "#order_confirmed" do
    before do
      Ordering::ReadModels::OrderSummary.create(
        order_id: "o1",
        order_number: "ORD-ABC",
        customer_email: "test@example.com",
        status: "pending",
        total_amount_cents: 2999,
        item_count: 2
      )
    end

    it "updates the summary status to confirmed" do
      event = Ordering::Events::OrderConfirmed.new(order_id: "o1", order_number: "ORD-ABC")
      listener.order_confirmed(event)

      summary = Ordering::ReadModels::OrderSummary.find_by(order_id: "o1")
      expect(summary.status).to eq("confirmed")
    end
  end

  describe "#order_cancelled" do
    before do
      Ordering::ReadModels::OrderSummary.create(
        order_id: "o1",
        order_number: "ORD-ABC",
        customer_email: "test@example.com",
        status: "pending",
        total_amount_cents: 2999,
        item_count: 2
      )
    end

    it "updates the summary status to cancelled" do
      event = Ordering::Events::OrderCancelled.new(
        order_id: "o1",
        order_number: "ORD-ABC",
        line_items: [],
        reason: "Customer request"
      )

      listener.order_cancelled(event)
      summary = Ordering::ReadModels::OrderSummary.find_by(order_id: "o1")
      expect(summary.status).to eq("cancelled")
    end
  end
end
