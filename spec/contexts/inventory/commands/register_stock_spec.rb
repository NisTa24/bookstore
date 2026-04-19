require "rails_helper"

RSpec.describe Inventory::Commands::RegisterStock do
  subject(:command) { described_class.new }

  let(:book_id) { SecureRandom.uuid }

  describe "#call" do
    context "with valid params" do
      it "creates a stock item" do
        expect {
          command.call(book_id: book_id, quantity: 10)
        }.to change(Inventory::StockItem, :count).by(1)
      end

      it "sets quantity_on_hand" do
        command.call(book_id: book_id, quantity: 10)
        stock = Inventory::StockItem.find_by(book_id: book_id)
        expect(stock.quantity_on_hand).to eq(10)
      end

      it "broadcasts :stock_registered" do
        event = nil
        command.on(:stock_registered) { |e| event = e }
        command.call(book_id: book_id, quantity: 10)

        expect(event).to be_a(Inventory::Events::StockRegistered)
        expect(event.book_id).to eq(book_id)
        expect(event.quantity_added).to eq(10)
        expect(event.new_total).to eq(10)
      end

      it "logs a domain event" do
        expect {
          command.call(book_id: book_id, quantity: 10)
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "when stock already exists" do
      before do
        Inventory::StockItem.create(book_id: book_id, quantity_on_hand: 5)
      end

      it "adds to existing quantity" do
        command.call(book_id: book_id, quantity: 10)
        stock = Inventory::StockItem.find_by(book_id: book_id)
        expect(stock.quantity_on_hand).to eq(15)
      end

      it "does not create a new stock item" do
        expect {
          command.call(book_id: book_id, quantity: 10)
        }.not_to change(Inventory::StockItem, :count)
      end
    end

    context "with invalid quantity" do
      it "broadcasts :register_stock_failed for zero" do
        errors = nil
        command.on(:register_stock_failed) { |e| errors = e }
        command.call(book_id: book_id, quantity: 0)

        expect(errors[:errors]).to include(match(/Quantity must be positive/))
      end

      it "broadcasts :register_stock_failed for negative" do
        errors = nil
        command.on(:register_stock_failed) { |e| errors = e }
        command.call(book_id: book_id, quantity: -5)

        expect(errors[:errors]).to include(match(/Quantity must be positive/))
      end
    end
  end
end
