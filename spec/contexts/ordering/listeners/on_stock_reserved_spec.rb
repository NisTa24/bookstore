require "rails_helper"

RSpec.describe Ordering::Listeners::OnStockReserved do
  subject(:listener) { described_class.new }

  describe "#stock_reserved" do
    context "when order is pending" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-RESERVE1",
          customer_email: "test@example.com",
          status: "pending"
        )
      end

      it "confirms the order" do
        event = Inventory::Events::StockReserved.new(
          order_id: order.id,
          book_id: SecureRandom.uuid,
          quantity: 3
        )

        listener.stock_reserved(event)
        expect(order.reload.status).to eq("confirmed")
      end
    end

    context "when order is not pending" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-RESERVE2",
          customer_email: "test@example.com",
          status: "confirmed"
        )
      end

      it "does not change the order status" do
        event = Inventory::Events::StockReserved.new(
          order_id: order.id,
          book_id: SecureRandom.uuid,
          quantity: 3
        )

        listener.stock_reserved(event)
        expect(order.reload.status).to eq("confirmed")
      end
    end

    context "when order does not exist" do
      it "does not raise an error" do
        event = Inventory::Events::StockReserved.new(
          order_id: "nonexistent",
          book_id: SecureRandom.uuid,
          quantity: 3
        )

        expect { listener.stock_reserved(event) }.not_to raise_error
      end
    end
  end
end
