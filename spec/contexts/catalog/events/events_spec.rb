require "rails_helper"

RSpec.describe "Catalog Domain Events" do
  describe Catalog::Events::BookAdded do
    it "is an immutable Data object with expected members" do
      event = described_class.new(
        book_id: "uuid-1",
        title: "DDD",
        isbn: "9780306406157",
        author_id: "uuid-2",
        category_id: "uuid-3"
      )

      expect(event.book_id).to eq("uuid-1")
      expect(event.title).to eq("DDD")
      expect(event.isbn).to eq("9780306406157")
      expect(event.author_id).to eq("uuid-2")
      expect(event.category_id).to eq("uuid-3")
      expect(event).to be_frozen
    end
  end

  describe Catalog::Events::BookUpdated do
    it "is an immutable Data object with expected members" do
      event = described_class.new(
        book_id: "uuid-1",
        title: "New Title",
        isbn: "9780306406157",
        changes: ["title"]
      )

      expect(event.book_id).to eq("uuid-1")
      expect(event.changes).to eq(["title"])
      expect(event).to be_frozen
    end
  end

  describe Catalog::Events::BookRetired do
    it "is an immutable Data object with expected members" do
      event = described_class.new(book_id: "uuid-1")
      expect(event.book_id).to eq("uuid-1")
      expect(event).to be_frozen
    end
  end
end
