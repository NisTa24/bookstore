require "rails_helper"

RSpec.describe Pricing::Price, type: :model do
  let(:book_id) { SecureRandom.uuid }

  def create_price(overrides = {})
    Pricing::Price.create({
      book_id: book_id,
      amount_cents: 999,
      currency: "USD",
      effective_from: 1.day.ago
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with all required attributes" do
      price = Pricing::Price.new(book_id: book_id, amount_cents: 999, currency: "USD", effective_from: Time.current)
      expect(price).to be_valid
    end

    it "is invalid without book_id" do
      price = Pricing::Price.new(book_id: nil, amount_cents: 999, currency: "USD", effective_from: Time.current)
      expect(price).not_to be_valid
    end

    it "is invalid without amount_cents" do
      price = Pricing::Price.new(book_id: book_id, amount_cents: nil, currency: "USD", effective_from: Time.current)
      expect(price).not_to be_valid
    end

    it "is invalid with negative amount_cents" do
      price = Pricing::Price.new(book_id: book_id, amount_cents: -1, currency: "USD", effective_from: Time.current)
      expect(price).not_to be_valid
    end

    it "accepts zero amount_cents" do
      price = Pricing::Price.new(book_id: book_id, amount_cents: 0, currency: "USD", effective_from: Time.current)
      expect(price).to be_valid
    end

    it "is invalid without currency" do
      price = Pricing::Price.new(book_id: book_id, amount_cents: 999, currency: nil, effective_from: Time.current)
      expect(price).not_to be_valid
    end

    it "is invalid without effective_from" do
      price = Pricing::Price.new(book_id: book_id, amount_cents: 999, currency: "USD", effective_from: nil)
      expect(price).not_to be_valid
    end
  end

  describe ".current_for_book" do
    it "returns the currently active price" do
      price = create_price(effective_from: 1.hour.ago, effective_until: nil)
      result = Pricing::Price.current_for_book(book_id).first
      expect(result).to eq(price)
    end

    it "excludes expired prices" do
      create_price(effective_from: 2.days.ago, effective_until: 1.day.ago)
      result = Pricing::Price.current_for_book(book_id).first
      expect(result).to be_nil
    end

    it "excludes future prices" do
      create_price(effective_from: 1.day.from_now, effective_until: nil)
      result = Pricing::Price.current_for_book(book_id).first
      expect(result).to be_nil
    end

    it "returns the most recent active price" do
      create_price(effective_from: 2.hours.ago, effective_until: nil)
      newer = create_price(book_id: book_id, effective_from: 1.hour.ago, effective_until: nil)
      result = Pricing::Price.current_for_book(book_id).first
      expect(result).to eq(newer)
    end
  end

  describe "#to_money" do
    it "returns a Money value object" do
      price = create_price(amount_cents: 1999, currency: "USD")
      money = price.to_money
      expect(money).to be_a(Pricing::ValueObjects::Money)
      expect(money.amount_cents).to eq(1999)
      expect(money.currency).to eq("USD")
    end
  end
end
