require "rails_helper"

RSpec.describe Inventory::Listeners::OnOrderPlaced do
  subject(:listener) { described_class.new }

  let(:book_id) { SecureRandom.uuid }

  describe "#order_placed" do
    before do
      Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 10, quantity_reserved: 0)
    end

    it "calls ReserveStock with mapped line items" do
      event = Ordering::Events::OrderPlaced.new(
        order_id: "o1",
        order_number: "ORD-ABC",
        customer_email: "test@example.com",
        line_items: [ { book_id: book_id, quantity: 3, unit_price_cents: 999, unit_price_currency: "USD" } ],
        total_amount_cents: 2997,
        currency: "USD"
      )

      listener.order_placed(event)

      stock = Inventory::StockItem.find_by(book_id: book_id)
      expect(stock.quantity_reserved).to eq(3)
    end
  end
end
