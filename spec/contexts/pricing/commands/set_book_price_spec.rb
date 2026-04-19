require "rails_helper"

RSpec.describe Pricing::Commands::SetBookPrice do
  subject(:command) { described_class.new }

  let(:book_id) { SecureRandom.uuid }

  describe "#call" do
    context "with valid params" do
      it "creates a price record" do
        expect {
          command.call(book_id: book_id, amount_cents: 1999)
        }.to change(Pricing::Price, :count).by(1)
      end

      it "sets amount and currency" do
        command.call(book_id: book_id, amount_cents: 1999, currency: "USD")
        price = Pricing::Price.last
        expect(price.amount_cents).to eq(1999)
        expect(price.currency).to eq("USD")
      end

      it "broadcasts :price_set" do
        event = nil
        command.on(:price_set) { |e| event = e }
        command.call(book_id: book_id, amount_cents: 1999)

        expect(event).to be_a(Pricing::Events::PriceSet)
        expect(event.book_id).to eq(book_id)
        expect(event.amount_cents).to eq(1999)
      end

      it "logs a domain event" do
        expect {
          command.call(book_id: book_id, amount_cents: 1999)
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "when replacing an existing price" do
      before do
        Pricing::Price.create(
          book_id: book_id,
          amount_cents: 999,
          currency: "USD",
          effective_from: 2.days.ago,
          effective_until: nil
        )
      end

      it "expires the old price" do
        command.call(book_id: book_id, amount_cents: 1999)
        old_price = Pricing::Price.where(book_id: book_id).order(:effective_from).first
        expect(old_price.effective_until).not_to be_nil
      end

      it "creates a new active price" do
        command.call(book_id: book_id, amount_cents: 1999)
        current = Pricing::Price.current_for_book(book_id).first
        expect(current.amount_cents).to eq(1999)
      end
    end

    context "with negative amount" do
      it "broadcasts :set_book_price_failed" do
        errors = nil
        command.on(:set_book_price_failed) { |e| errors = e }
        command.call(book_id: book_id, amount_cents: -100)

        expect(errors[:errors]).to include(match(/non-negative/))
      end
    end
  end
end
