require "rails_helper"

RSpec.describe "Ordering Domain Events" do
  describe Ordering::Events::OrderPlaced do
    it "holds all order data" do
      event = described_class.new(
        order_id: "o1",
        order_number: "ORD-ABC",
        customer_email: "test@example.com",
        line_items: [{ book_id: "b1", quantity: 2 }],
        total_amount_cents: 1999,
        currency: "USD"
      )

      expect(event.order_id).to eq("o1")
      expect(event.order_number).to eq("ORD-ABC")
      expect(event.customer_email).to eq("test@example.com")
      expect(event.line_items.size).to eq(1)
      expect(event.total_amount_cents).to eq(1999)
      expect(event.currency).to eq("USD")
      expect(event).to be_frozen
    end
  end

  describe Ordering::Events::OrderConfirmed do
    it "holds order_id and order_number" do
      event = described_class.new(order_id: "o1", order_number: "ORD-ABC")
      expect(event.order_id).to eq("o1")
      expect(event.order_number).to eq("ORD-ABC")
    end
  end

  describe Ordering::Events::OrderCancelled do
    it "holds order details and reason" do
      event = described_class.new(
        order_id: "o1",
        order_number: "ORD-ABC",
        line_items: [],
        reason: "Out of stock"
      )

      expect(event.reason).to eq("Out of stock")
      expect(event.line_items).to eq([])
    end
  end
end
