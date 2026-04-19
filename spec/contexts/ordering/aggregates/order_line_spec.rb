require "rails_helper"

RSpec.describe Ordering::OrderLine, type: :model do
  let(:order) do
    Ordering::Order.create(
      order_number: "ORD-#{SecureRandom.hex(6).upcase}",
      customer_email: "test@example.com",
      status: "pending"
    )
  end

  describe "validations" do
    it "is valid with all required attributes" do
      line = Ordering::OrderLine.new(
        order: order,
        book_id: SecureRandom.uuid,
        quantity: 2,
        unit_price_cents: 999
      )
      expect(line).to be_valid
    end

    it "is invalid without book_id" do
      line = Ordering::OrderLine.new(order: order, book_id: nil, quantity: 1, unit_price_cents: 999)
      expect(line).not_to be_valid
      expect(line.errors[:book_id]).to include("can't be blank")
    end

    it "is invalid without quantity" do
      line = Ordering::OrderLine.new(order: order, book_id: SecureRandom.uuid, quantity: nil, unit_price_cents: 999)
      expect(line).not_to be_valid
    end

    it "is invalid with zero quantity" do
      line = Ordering::OrderLine.new(order: order, book_id: SecureRandom.uuid, quantity: 0, unit_price_cents: 999)
      expect(line).not_to be_valid
    end

    it "is invalid with negative quantity" do
      line = Ordering::OrderLine.new(order: order, book_id: SecureRandom.uuid, quantity: -1, unit_price_cents: 999)
      expect(line).not_to be_valid
    end

    it "is invalid without unit_price_cents" do
      line = Ordering::OrderLine.new(order: order, book_id: SecureRandom.uuid, quantity: 1, unit_price_cents: nil)
      expect(line).not_to be_valid
    end

    it "is invalid with negative unit_price_cents" do
      line = Ordering::OrderLine.new(order: order, book_id: SecureRandom.uuid, quantity: 1, unit_price_cents: -1)
      expect(line).not_to be_valid
    end

    it "accepts zero unit_price_cents" do
      line = Ordering::OrderLine.new(order: order, book_id: SecureRandom.uuid, quantity: 1, unit_price_cents: 0)
      expect(line).to be_valid
    end
  end

  describe "#subtotal_cents" do
    it "returns quantity times unit_price_cents" do
      line = Ordering::OrderLine.new(quantity: 3, unit_price_cents: 500)
      expect(line.subtotal_cents).to eq(1500)
    end
  end

  describe "#set_uuid" do
    it "generates a UUID on create" do
      line = Ordering::OrderLine.create(order: order, book_id: SecureRandom.uuid, quantity: 1, unit_price_cents: 999)
      expect(line.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end
end
