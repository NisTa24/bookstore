require "rails_helper"

RSpec.describe Ordering::Order, type: :model do
  def create_order(overrides = {})
    Ordering::Order.create({
      order_number: "ORD-#{SecureRandom.hex(6).upcase}",
      customer_email: "test@example.com",
      status: "pending",
      total_amount_cents: 1000,
      total_currency: "USD"
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with all required attributes" do
      order = Ordering::Order.new(
        order_number: "ORD-ABC123",
        customer_email: "test@example.com",
        status: "pending"
      )
      expect(order).to be_valid
    end

    it "is invalid without order_number" do
      order = Ordering::Order.new(order_number: nil, customer_email: "test@example.com", status: "pending")
      expect(order).not_to be_valid
      expect(order.errors[:order_number]).to include("can't be blank")
    end

    it "enforces order_number uniqueness" do
      create_order(order_number: "ORD-UNIQUE")
      duplicate = Ordering::Order.new(order_number: "ORD-UNIQUE", customer_email: "test@example.com", status: "pending")
      expect(duplicate).not_to be_valid
    end

    it "is invalid without customer_email" do
      order = Ordering::Order.new(order_number: "ORD-123", customer_email: nil, status: "pending")
      expect(order).not_to be_valid
    end

    it "validates status inclusion" do
      order = Ordering::Order.new(order_number: "ORD-123", customer_email: "test@example.com", status: "invalid")
      expect(order).not_to be_valid
      expect(order.errors[:status]).to include("is not included in the list")
    end

    %w[pending confirmed fulfilled cancelled].each do |valid_status|
      it "accepts #{valid_status} status" do
        order = Ordering::Order.new(order_number: "ORD-123", customer_email: "test@example.com", status: valid_status)
        expect(order).to be_valid
      end
    end
  end

  describe "associations" do
    it "has many order_lines" do
      order = create_order
      line = Ordering::OrderLine.create(
        order: order,
        book_id: SecureRandom.uuid,
        quantity: 1,
        unit_price_cents: 999
      )
      expect(order.order_lines).to include(line)
    end

    it "destroys order_lines on destroy" do
      order = create_order
      Ordering::OrderLine.create(
        order: order,
        book_id: SecureRandom.uuid,
        quantity: 1,
        unit_price_cents: 999
      )
      expect { order.destroy }.to change(Ordering::OrderLine, :count).by(-1)
    end
  end

  describe "#confirm!" do
    it "sets status to confirmed" do
      order = create_order(status: "pending")
      order.confirm!
      expect(order.reload.status).to eq("confirmed")
    end
  end

  describe "#cancel!" do
    it "sets status to cancelled" do
      order = create_order(status: "pending")
      order.cancel!
      expect(order.reload.status).to eq("cancelled")
    end
  end

  describe "#pending?" do
    it "returns true when pending" do
      order = create_order(status: "pending")
      expect(order.pending?).to be true
    end

    it "returns false when confirmed" do
      order = create_order(status: "confirmed")
      expect(order.pending?).to be false
    end
  end

  describe "#confirmed?" do
    it "returns true when confirmed" do
      order = create_order(status: "confirmed")
      expect(order.confirmed?).to be true
    end

    it "returns false when pending" do
      order = create_order(status: "pending")
      expect(order.confirmed?).to be false
    end
  end
end
