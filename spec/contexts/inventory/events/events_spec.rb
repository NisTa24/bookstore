require "rails_helper"

RSpec.describe "Inventory Domain Events" do
  describe Inventory::Events::StockRegistered do
    it "holds book_id, quantity_added, and new_total" do
      event = described_class.new(book_id: "b1", quantity_added: 10, new_total: 25)
      expect(event.book_id).to eq("b1")
      expect(event.quantity_added).to eq(10)
      expect(event.new_total).to eq(25)
      expect(event).to be_frozen
    end
  end

  describe Inventory::Events::StockReserved do
    it "holds order_id, book_id, and quantity" do
      event = described_class.new(order_id: "o1", book_id: "b1", quantity: 3)
      expect(event.order_id).to eq("o1")
      expect(event.book_id).to eq("b1")
      expect(event.quantity).to eq(3)
    end
  end

  describe Inventory::Events::StockDepleted do
    it "holds order_id, book_id, requested and available quantities" do
      event = described_class.new(order_id: "o1", book_id: "b1", requested_quantity: 5, available_quantity: 2)
      expect(event.requested_quantity).to eq(5)
      expect(event.available_quantity).to eq(2)
    end
  end

  describe Inventory::Events::StockReleased do
    it "holds order_id, book_id, and quantity" do
      event = described_class.new(order_id: "o1", book_id: "b1", quantity: 3)
      expect(event.quantity).to eq(3)
    end
  end
end
