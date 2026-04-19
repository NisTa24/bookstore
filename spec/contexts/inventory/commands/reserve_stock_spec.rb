require "rails_helper"

RSpec.describe Inventory::Commands::ReserveStock do
  subject(:command) { described_class.new }

  let(:order_id) { SecureRandom.uuid }
  let(:book_id) { SecureRandom.uuid }

  describe "#call" do
    context "when stock is available" do
      before do
        Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 10, quantity_reserved: 0)
      end

      it "reserves the stock" do
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])
        stock = Inventory::StockItem.find_by(book_id: book_id)
        expect(stock.quantity_reserved).to eq(3)
      end

      it "broadcasts :stock_reserved" do
        event = nil
        command.on(:stock_reserved) { |e| event = e }
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])

        expect(event).to be_a(Inventory::Events::StockReserved)
        expect(event.order_id).to eq(order_id)
        expect(event.book_id).to eq(book_id)
        expect(event.quantity).to eq(3)
      end

      it "logs domain events" do
        expect {
          command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "when stock is insufficient" do
      before do
        Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 2, quantity_reserved: 0)
      end

      it "broadcasts :stock_depleted" do
        event = nil
        command.on(:stock_depleted) { |e| event = e }
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 5 } ])

        expect(event).to be_a(Inventory::Events::StockDepleted)
        expect(event.order_id).to eq(order_id)
        expect(event.book_id).to eq(book_id)
        expect(event.requested_quantity).to eq(5)
        expect(event.available_quantity).to eq(2)
      end

      it "does not reserve any stock" do
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 5 } ])
        stock = Inventory::StockItem.find_by(book_id: book_id)
        expect(stock.quantity_reserved).to eq(0)
      end
    end

    context "when no stock record exists" do
      it "broadcasts :stock_depleted" do
        event = nil
        command.on(:stock_depleted) { |e| event = e }
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 1 } ])

        expect(event).to be_a(Inventory::Events::StockDepleted)
        expect(event.available_quantity).to eq(0)
      end
    end

    context "with multiple items" do
      let(:book_id_2) { SecureRandom.uuid }

      before do
        Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 10, quantity_reserved: 0)
        Inventory::StockItem.create(book_id: book_id_2, quantity_on_hand: 10, quantity_reserved: 0)
      end

      it "reserves all items" do
        events = []
        command.on(:stock_reserved) { |e| events << e }
        command.call(order_id: order_id, items: [
          { book_id: book_id, quantity: 2 },
          { book_id: book_id_2, quantity: 3 }
        ])

        expect(events.size).to eq(2)
      end
    end
  end
end
