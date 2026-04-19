require "rails_helper"

RSpec.describe Inventory::ValueObjects::Quantity do
  describe "#initialize" do
    it "accepts a positive integer" do
      qty = described_class.new(value: 5)
      expect(qty.value).to eq(5)
    end

    it "coerces string to integer" do
      qty = described_class.new(value: "10")
      expect(qty.value).to eq(10)
    end

    it "raises ArgumentError for zero" do
      expect { described_class.new(value: 0) }.to raise_error(ArgumentError, /Quantity must be positive/)
    end

    it "raises ArgumentError for negative value" do
      expect { described_class.new(value: -1) }.to raise_error(ArgumentError, /Quantity must be positive/)
    end
  end

  describe "#to_i" do
    it "returns the integer value" do
      qty = described_class.new(value: 7)
      expect(qty.to_i).to eq(7)
    end
  end

  describe "#to_s" do
    it "returns the string representation" do
      qty = described_class.new(value: 7)
      expect(qty.to_s).to eq("7")
    end
  end

  describe "immutability" do
    it "is a frozen Data object" do
      qty = described_class.new(value: 1)
      expect(qty).to be_frozen
    end
  end
end
