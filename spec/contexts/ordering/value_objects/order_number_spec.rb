require "rails_helper"

RSpec.describe Ordering::ValueObjects::OrderNumber do
  describe "#initialize" do
    it "auto-generates an order number when no value given" do
      order_number = described_class.new
      expect(order_number.value).to match(/\AORD-[A-F0-9]{12}\z/)
    end

    it "accepts a provided value" do
      order_number = described_class.new(value: "ORD-CUSTOM123")
      expect(order_number.value).to eq("ORD-CUSTOM123")
    end

    it "generates unique order numbers" do
      numbers = Array.new(10) { described_class.new.value }
      expect(numbers.uniq.size).to eq(10)
    end
  end

  describe "#to_s" do
    it "returns the value" do
      order_number = described_class.new(value: "ORD-ABC123")
      expect(order_number.to_s).to eq("ORD-ABC123")
    end
  end

  describe "immutability" do
    it "is a frozen Data object" do
      order_number = described_class.new
      expect(order_number).to be_frozen
    end
  end
end
