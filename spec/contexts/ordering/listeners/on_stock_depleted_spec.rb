require "rails_helper"

RSpec.describe Ordering::Listeners::OnStockDepleted do
  subject(:listener) { described_class.new }

  describe "#stock_depleted" do
    let!(:order) do
      Ordering::Order.create(
        order_number: "ORD-DEPLETED1",
        customer_email: "test@example.com",
        status: "pending"
      )
    end

    it "cancels the order with an insufficient stock reason" do
      event = Inventory::Events::StockDepleted.new(
        order_id: order.id,
        book_id: "book-uuid",
        requested_quantity: 5,
        available_quantity: 2
      )

      listener.stock_depleted(event)
      expect(order.reload.status).to eq("cancelled")
    end
  end
end
