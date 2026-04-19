require "rails_helper"

RSpec.describe Pricing::ValueObjects::Percentage do
  describe "#initialize" do
    it "accepts value between 0 and 100" do
      pct = described_class.new(value: 25)
      expect(pct.value).to eq(25.0)
    end

    it "accepts zero" do
      pct = described_class.new(value: 0)
      expect(pct.value).to eq(0.0)
    end

    it "accepts 100" do
      pct = described_class.new(value: 100)
      expect(pct.value).to eq(100.0)
    end

    it "coerces string to float" do
      pct = described_class.new(value: "50")
      expect(pct.value).to eq(50.0)
    end

    it "raises ArgumentError for negative value" do
      expect { described_class.new(value: -1) }.to raise_error(ArgumentError, /between 0 and 100/)
    end

    it "raises ArgumentError for value over 100" do
      expect { described_class.new(value: 101) }.to raise_error(ArgumentError, /between 0 and 100/)
    end
  end

  describe "#to_f" do
    it "returns the float value" do
      pct = described_class.new(value: 33.5)
      expect(pct.to_f).to eq(33.5)
    end
  end

  describe "#to_s" do
    it "formats with percent sign" do
      pct = described_class.new(value: 25)
      expect(pct.to_s).to eq("25.0%")
    end
  end

  describe "immutability" do
    it "is a frozen Data object" do
      pct = described_class.new(value: 50)
      expect(pct).to be_frozen
    end
  end
end
