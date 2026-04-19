require "rails_helper"

RSpec.describe Ordering::Commands::CancelOrder do
  subject(:command) { described_class.new }

  describe "#call" do
    context "when order is pending" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-CANCEL1",
          customer_email: "test@example.com",
          status: "pending"
        )
      end

      it "cancels the order" do
        command.call(order_id: order.id)
        expect(order.reload.status).to eq("cancelled")
      end

      it "broadcasts :order_cancelled" do
        event = nil
        command.on(:order_cancelled) { |e| event = e }
        command.call(order_id: order.id)

        expect(event).to be_a(Ordering::Events::OrderCancelled)
        expect(event.order_id).to eq(order.id)
        expect(event.reason).to eq("Cancelled by customer")
      end

      it "includes line items in the event" do
        Ordering::OrderLine.create(
          order: order,
          book_id: SecureRandom.uuid,
          quantity: 2,
          unit_price_cents: 999
        )

        event = nil
        command.on(:order_cancelled) { |e| event = e }
        command.call(order_id: order.id)

        expect(event.line_items.size).to eq(1)
        expect(event.line_items.first[:quantity]).to eq(2)
      end

      it "accepts a custom reason" do
        event = nil
        command.on(:order_cancelled) { |e| event = e }
        command.call(order_id: order.id, reason: "Out of stock")

        expect(event.reason).to eq("Out of stock")
      end
    end

    context "when order is confirmed" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-CANCEL2",
          customer_email: "test@example.com",
          status: "confirmed"
        )
      end

      it "can cancel a confirmed order" do
        command.call(order_id: order.id)
        expect(order.reload.status).to eq("cancelled")
      end
    end

    context "when order is already cancelled" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-CANCEL3",
          customer_email: "test@example.com",
          status: "cancelled"
        )
      end

      it "broadcasts :cancel_order_failed" do
        errors = nil
        command.on(:cancel_order_failed) { |e| errors = e }
        command.call(order_id: order.id)

        expect(errors[:errors]).to include(match(/cannot be cancelled/))
      end
    end

    context "when order does not exist" do
      it "broadcasts :cancel_order_failed" do
        errors = nil
        command.on(:cancel_order_failed) { |e| errors = e }
        command.call(order_id: "nonexistent")

        expect(errors[:errors]).to include(match(/Order not found/))
      end
    end
  end
end
