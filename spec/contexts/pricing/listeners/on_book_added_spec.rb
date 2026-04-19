require "rails_helper"

RSpec.describe Pricing::Listeners::OnBookAdded do
  subject(:listener) { described_class.new }

  describe "#book_added" do
    it "creates a default price of $9.99 for the new book" do
      event = Catalog::Events::BookAdded.new(
        book_id: "uuid-1",
        title: "New Book",
        isbn: "9780306406157",
        author_id: nil,
        category_id: nil
      )

      expect { listener.book_added(event) }
        .to change(Pricing::Price, :count).by(1)

      price = Pricing::Price.current_for_book("uuid-1").first
      expect(price.amount_cents).to eq(999)
      expect(price.currency).to eq("USD")
    end
  end
end
