require "rails_helper"

RSpec.describe "Pricing Domain Events" do
  describe Pricing::Events::PriceSet do
    it "holds price data" do
      event = described_class.new(book_id: "b1", amount_cents: 1999, currency: "USD", price_id: "p1")
      expect(event.book_id).to eq("b1")
      expect(event.amount_cents).to eq(1999)
      expect(event.currency).to eq("USD")
      expect(event.price_id).to eq("p1")
      expect(event).to be_frozen
    end
  end

  describe Pricing::Events::DiscountApplied do
    it "holds discount data" do
      event = described_class.new(book_id: "b1", original_cents: 2000, discounted_cents: 1800, rule_name: "10% Off")
      expect(event.original_cents).to eq(2000)
      expect(event.discounted_cents).to eq(1800)
      expect(event.rule_name).to eq("10% Off")
    end
  end
end
