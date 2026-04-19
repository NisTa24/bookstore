require "rails_helper"

RSpec.describe Pricing::Commands::ApplyDiscount do
  subject(:command) { described_class.new }

  let(:book_id) { SecureRandom.uuid }

  describe "#call" do
    context "with a percentage discount" do
      let!(:price) do
        Pricing::Price.create(
          book_id: book_id,
          amount_cents: 2000,
          currency: "USD",
          effective_from: 1.day.ago
        )
      end

      let!(:rule) do
        Pricing::DiscountRule.create(
          name: "10% Off",
          discount_type: "percentage",
          value: 10,
          active: true,
          valid_from: 1.day.ago
        )
      end

      it "broadcasts :discount_applied with correct amounts" do
        event = nil
        command.on(:discount_applied) { |e| event = e }
        command.call(book_id: book_id, rule_id: rule.id)

        expect(event).to be_a(Pricing::Events::DiscountApplied)
        expect(event.original_cents).to eq(2000)
        expect(event.discounted_cents).to eq(1800)
        expect(event.rule_name).to eq("10% Off")
      end

      it "logs a domain event" do
        expect {
          command.call(book_id: book_id, rule_id: rule.id)
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "with a fixed_amount discount" do
      let!(:price) do
        Pricing::Price.create(
          book_id: book_id,
          amount_cents: 2000,
          currency: "USD",
          effective_from: 1.day.ago
        )
      end

      let!(:rule) do
        Pricing::DiscountRule.create(
          name: "$5 Off",
          discount_type: "fixed_amount",
          value: 500,
          active: true,
          valid_from: 1.day.ago
        )
      end

      it "subtracts the fixed amount" do
        event = nil
        command.on(:discount_applied) { |e| event = e }
        command.call(book_id: book_id, rule_id: rule.id)

        expect(event.discounted_cents).to eq(1500)
      end
    end

    context "when no current price exists" do
      let!(:rule) do
        Pricing::DiscountRule.create(
          name: "Sale",
          discount_type: "percentage",
          value: 10,
          active: true,
          valid_from: 1.day.ago
        )
      end

      it "broadcasts :apply_discount_failed" do
        errors = nil
        command.on(:apply_discount_failed) { |e| errors = e }
        command.call(book_id: book_id, rule_id: rule.id)

        expect(errors[:errors]).to include(match(/No current price/))
      end
    end

    context "when discount rule does not exist" do
      it "broadcasts :apply_discount_failed" do
        errors = nil
        command.on(:apply_discount_failed) { |e| errors = e }
        command.call(book_id: book_id, rule_id: "nonexistent")

        expect(errors[:errors]).to include(match(/Discount rule not found/))
      end
    end
  end
end
