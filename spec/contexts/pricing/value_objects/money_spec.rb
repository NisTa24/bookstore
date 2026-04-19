require "rails_helper"

RSpec.describe Pricing::ValueObjects::Money do
  describe "#initialize" do
    it "accepts non-negative amount_cents and currency" do
      money = described_class.new(amount_cents: 1000, currency: "USD")
      expect(money.amount_cents).to eq(1000)
      expect(money.currency).to eq("USD")
    end

    it "defaults currency to USD" do
      money = described_class.new(amount_cents: 500)
      expect(money.currency).to eq("USD")
    end

    it "uppercases currency" do
      money = described_class.new(amount_cents: 500, currency: "eur")
      expect(money.currency).to eq("EUR")
    end

    it "accepts zero amount" do
      money = described_class.new(amount_cents: 0)
      expect(money.amount_cents).to eq(0)
    end

    it "raises ArgumentError for negative amount" do
      expect { described_class.new(amount_cents: -1) }.to raise_error(ArgumentError, /non-negative/)
    end
  end

  describe "#to_f" do
    it "converts cents to dollars" do
      money = described_class.new(amount_cents: 1999)
      expect(money.to_f).to eq(19.99)
    end
  end

  describe "#+" do
    it "adds two money objects with same currency" do
      a = described_class.new(amount_cents: 1000)
      b = described_class.new(amount_cents: 500)
      result = a + b
      expect(result.amount_cents).to eq(1500)
      expect(result.currency).to eq("USD")
    end

    it "raises ArgumentError for currency mismatch" do
      a = described_class.new(amount_cents: 1000, currency: "USD")
      b = described_class.new(amount_cents: 500, currency: "EUR")
      expect { a + b }.to raise_error(ArgumentError, /Currency mismatch/)
    end
  end

  describe "#*" do
    it "multiplies by a scalar" do
      money = described_class.new(amount_cents: 1000)
      result = money * 3
      expect(result.amount_cents).to eq(3000)
    end

    it "rounds to nearest cent" do
      money = described_class.new(amount_cents: 100)
      result = money * 0.333
      expect(result.amount_cents).to eq(33)
    end
  end

  describe "#apply_percentage_discount" do
    it "applies a percentage discount" do
      money = described_class.new(amount_cents: 1000)
      result = money.apply_percentage_discount(10)
      expect(result.amount_cents).to eq(900)
    end

    it "applies a 50% discount" do
      money = described_class.new(amount_cents: 2000)
      result = money.apply_percentage_discount(50)
      expect(result.amount_cents).to eq(1000)
    end
  end

  describe "#to_s" do
    it "formats as dollars with currency" do
      money = described_class.new(amount_cents: 1999, currency: "USD")
      expect(money.to_s).to eq("19.99 USD")
    end
  end

  describe "immutability" do
    it "is a frozen Data object" do
      money = described_class.new(amount_cents: 100)
      expect(money).to be_frozen
    end
  end
end
