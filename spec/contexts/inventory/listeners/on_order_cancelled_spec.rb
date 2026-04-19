require "rails_helper"

RSpec.describe Inventory::Listeners::OnOrderCancelled do
  subject(:listener) { described_class.new }

  let(:book_id) { SecureRandom.uuid }

  describe "#order_cancelled" do
    before do
      Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 10, quantity_reserved: 5)
    end

    it "releases the reserved stock" do
      event = Ordering::Events::OrderCancelled.new(
        order_id: "o1",
        order_number: "ORD-ABC",
        line_items: [ { book_id: book_id, quantity: 3 } ],
        reason: "Cancelled"
      )

      listener.order_cancelled(event)

      stock = Inventory::StockItem.find_by(book_id: book_id)
      expect(stock.quantity_reserved).to eq(2)
    end
  end
end
