require "rails_helper"

RSpec.describe Ordering::Commands::ConfirmOrder do
  subject(:command) { described_class.new }

  describe "#call" do
    context "when order is pending" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-TEST123",
          customer_email: "test@example.com",
          status: "pending"
        )
      end

      it "confirms the order" do
        command.call(order_id: order.id)
        expect(order.reload.status).to eq("confirmed")
      end

      it "broadcasts :order_confirmed" do
        event = nil
        command.on(:order_confirmed) { |e| event = e }
        command.call(order_id: order.id)

        expect(event).to be_a(Ordering::Events::OrderConfirmed)
        expect(event.order_id).to eq(order.id)
        expect(event.order_number).to eq("ORD-TEST123")
      end

      it "logs a domain event" do
        expect {
          command.call(order_id: order.id)
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "when order is not pending" do
      let!(:order) do
        Ordering::Order.create(
          order_number: "ORD-CONFIRMED",
          customer_email: "test@example.com",
          status: "confirmed"
        )
      end

      it "broadcasts :confirm_order_failed" do
        errors = nil
        command.on(:confirm_order_failed) { |e| errors = e }
        command.call(order_id: order.id)

        expect(errors[:errors]).to include(match(/not pending/))
      end
    end

    context "when order does not exist" do
      it "broadcasts :confirm_order_failed" do
        errors = nil
        command.on(:confirm_order_failed) { |e| errors = e }
        command.call(order_id: "nonexistent")

        expect(errors[:errors]).to include(match(/Order not found/))
      end
    end
  end
end
