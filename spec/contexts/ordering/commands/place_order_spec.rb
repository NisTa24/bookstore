require "rails_helper"

RSpec.describe Ordering::Commands::PlaceOrder do
  subject(:command) { described_class.new }

  let(:book_id) { SecureRandom.uuid }

  before do
    Pricing::Price.create(
      book_id: book_id,
      amount_cents: 1999,
      currency: "USD",
      effective_from: 1.day.ago
    )
  end

  describe "#call" do
    context "with valid params" do
      it "creates an order" do
        expect {
          command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 2 } ])
        }.to change(Ordering::Order, :count).by(1)
      end

      it "creates order lines" do
        expect {
          command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 2 } ])
        }.to change(Ordering::OrderLine, :count).by(1)
      end

      it "calculates total correctly" do
        command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 2 } ])
        order = Ordering::Order.last
        expect(order.total_amount_cents).to eq(3998)
      end

      it "sets status to pending" do
        command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 2 } ])
        expect(Ordering::Order.last.status).to eq("pending")
      end

      it "broadcasts :order_placed" do
        event = nil
        command.on(:order_placed) { |e| event = e }
        command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 2 } ])

        expect(event).to be_a(Ordering::Events::OrderPlaced)
        expect(event.customer_email).to eq("buyer@example.com")
        expect(event.total_amount_cents).to eq(3998)
        expect(event.line_items.size).to eq(1)
      end

      it "generates an order number" do
        command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 1 } ])
        expect(Ordering::Order.last.order_number).to match(/\AORD-/)
      end

      it "logs a domain event" do
        expect {
          command.call(customer_email: "buyer@example.com", items: [ { book_id: book_id, quantity: 1 } ])
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "with invalid email" do
      it "broadcasts :place_order_failed" do
        errors = nil
        command.on(:place_order_failed) { |e| errors = e }
        command.call(customer_email: "bad-email", items: [ { book_id: book_id, quantity: 1 } ])

        expect(errors[:errors]).to include(match(/Invalid email/))
      end
    end

    context "with no price for book" do
      let(:unpriced_book_id) { SecureRandom.uuid }

      it "broadcasts :place_order_failed" do
        errors = nil
        command.on(:place_order_failed) { |e| errors = e }
        command.call(customer_email: "buyer@example.com", items: [ { book_id: unpriced_book_id, quantity: 1 } ])

        expect(errors[:errors]).to include(match(/No price found/))
      end

      it "does not create an order" do
        expect {
          command.call(customer_email: "buyer@example.com", items: [ { book_id: unpriced_book_id, quantity: 1 } ])
        }.not_to change(Ordering::Order, :count)
      end
    end
  end
end
