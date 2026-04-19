require "rails_helper"

RSpec.describe Catalog::Commands::AddBook do
  subject(:command) { described_class.new }

  let(:valid_isbn) { "9780306406157" }

  describe "#call" do
    context "with valid params" do
      it "creates a book" do
        expect {
          command.call(title: "Clean Code", isbn: valid_isbn)
        }.to change(Catalog::Book, :count).by(1)
      end

      it "broadcasts :book_added" do
        event = nil
        command.on(:book_added) { |e| event = e }
        command.call(title: "Clean Code", isbn: valid_isbn)

        expect(event).to be_a(Catalog::Events::BookAdded)
        expect(event.title).to eq("Clean Code")
        expect(event.isbn).to eq(valid_isbn)
      end

      it "logs a domain event" do
        expect {
          command.call(title: "Clean Code", isbn: valid_isbn)
        }.to change(Shared::DomainEventLog, :count).by(1)

        log = Shared::DomainEventLog.last
        expect(log.event_type).to eq("book_added")
        expect(log.source_command).to eq("Catalog::Commands::AddBook")
      end

      it "sets the book status to active" do
        command.call(title: "Clean Code", isbn: valid_isbn)
        expect(Catalog::Book.last.status).to eq("active")
      end

      it "accepts optional author_id and category_id" do
        author = Catalog::Author.create!(name: "Uncle Bob")
        category = Catalog::Category.create!(name: "Software", slug: "software")

        command.call(title: "Clean Code", isbn: valid_isbn, author_id: author.id, category_id: category.id)

        book = Catalog::Book.last
        expect(book.author_id).to eq(author.id)
        expect(book.category_id).to eq(category.id)
      end
    end

    context "with duplicate ISBN" do
      before do
        Catalog::Book.create!(title: "Existing", isbn: valid_isbn, status: "active")
      end

      it "does not create a book" do
        expect {
          command.call(title: "Duplicate", isbn: valid_isbn)
        }.not_to change(Catalog::Book, :count)
      end

      it "broadcasts :add_book_failed" do
        errors = nil
        command.on(:add_book_failed) { |e| errors = e }
        command.call(title: "Duplicate", isbn: valid_isbn)

        expect(errors[:errors]).to include(match(/ISBN already exists/))
      end
    end

    context "with invalid ISBN format" do
      it "broadcasts :add_book_failed" do
        errors = nil
        command.on(:add_book_failed) { |e| errors = e }
        command.call(title: "Bad ISBN", isbn: "invalid")

        expect(errors[:errors]).to include(match(/Invalid ISBN/))
      end
    end

    context "with missing title" do
      it "broadcasts :add_book_failed" do
        errors = nil
        command.on(:add_book_failed) { |e| errors = e }
        command.call(title: "", isbn: valid_isbn)

        expect(errors[:errors]).to include("Title can't be blank")
      end
    end
  end
end
