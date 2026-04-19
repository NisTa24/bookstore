require "rails_helper"

RSpec.describe Catalog::Listeners::UpdateBookListing do
  subject(:listener) { described_class.new }

  describe "#book_added" do
    let(:author) { Catalog::Author.create(name: "Eric Evans") }
    let(:category) { Catalog::Category.create(name: "Software", slug: "software") }

    it "creates a BookListing read model" do
      event = Catalog::Events::BookAdded.new(
        book_id: "uuid-1",
        title: "DDD",
        isbn: "9780306406157",
        author_id: author.id,
        category_id: category.id
      )

      expect { listener.book_added(event) }
        .to change(Catalog::ReadModels::BookListing, :count).by(1)

      listing = Catalog::ReadModels::BookListing.find_by(book_id: "uuid-1")
      expect(listing.title).to eq("DDD")
      expect(listing.isbn).to eq("9780306406157")
      expect(listing.author_name).to eq("Eric Evans")
      expect(listing.category_name).to eq("Software")
      expect(listing.status).to eq("active")
    end

    it "handles nil author_id and category_id" do
      event = Catalog::Events::BookAdded.new(
        book_id: "uuid-2",
        title: "No Author",
        isbn: "9780306406157",
        author_id: nil,
        category_id: nil
      )

      listener.book_added(event)
      listing = Catalog::ReadModels::BookListing.find_by(book_id: "uuid-2")
      expect(listing.author_name).to be_nil
      expect(listing.category_name).to be_nil
    end
  end

  describe "#book_updated" do
    before do
      Catalog::ReadModels::BookListing.create(
        book_id: "uuid-1",
        title: "Old Title",
        isbn: "9780306406157",
        status: "active"
      )
    end

    it "updates the listing title and isbn" do
      event = Catalog::Events::BookUpdated.new(
        book_id: "uuid-1",
        title: "New Title",
        isbn: "9780134685991",
        changes: [ "title", "isbn" ]
      )

      listener.book_updated(event)
      listing = Catalog::ReadModels::BookListing.find_by(book_id: "uuid-1")
      expect(listing.title).to eq("New Title")
      expect(listing.isbn).to eq("9780134685991")
    end

    it "does nothing if listing not found" do
      event = Catalog::Events::BookUpdated.new(
        book_id: "nonexistent",
        title: "X",
        isbn: "0000000000",
        changes: []
      )

      expect { listener.book_updated(event) }.not_to raise_error
    end
  end

  describe "#book_retired" do
    before do
      Catalog::ReadModels::BookListing.create(
        book_id: "uuid-1",
        title: "To Retire",
        isbn: "9780306406157",
        status: "active"
      )
    end

    it "sets the listing status to retired" do
      event = Catalog::Events::BookRetired.new(book_id: "uuid-1")
      listener.book_retired(event)

      listing = Catalog::ReadModels::BookListing.find_by(book_id: "uuid-1")
      expect(listing.status).to eq("retired")
    end

    it "does nothing if listing not found" do
      event = Catalog::Events::BookRetired.new(book_id: "nonexistent")
      expect { listener.book_retired(event) }.not_to raise_error
    end
  end
end
