require "rails_helper"

RSpec.describe Inventory::Commands::ReleaseStock do
  subject(:command) { described_class.new }

  let(:order_id) { SecureRandom.uuid }
  let(:book_id) { SecureRandom.uuid }

  describe "#call" do
    context "when stock exists with reservations" do
      before do
        Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 10, quantity_reserved: 5)
      end

      it "releases the reserved stock" do
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])
        stock = Inventory::StockItem.find_by(book_id: book_id)
        expect(stock.quantity_reserved).to eq(2)
      end

      it "broadcasts :stock_released" do
        event = nil
        command.on(:stock_released) { |e| event = e }
        command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])

        expect(event).to be_a(Inventory::Events::StockReleased)
        expect(event.order_id).to eq(order_id)
        expect(event.book_id).to eq(book_id)
        expect(event.quantity).to eq(3)
      end

      it "logs a domain event" do
        expect {
          command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "when stock does not exist" do
      it "does not raise an error" do
        expect {
          command.call(order_id: order_id, items: [ { book_id: book_id, quantity: 3 } ])
        }.not_to raise_error
      end
    end
  end
end
