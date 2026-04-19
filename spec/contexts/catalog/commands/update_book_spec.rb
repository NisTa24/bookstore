require "rails_helper"

RSpec.describe Catalog::Commands::UpdateBook do
  subject(:command) { described_class.new }

  let!(:book) { Catalog::Book.create(title: "Old Title", isbn: "9780306406157", status: "active") }

  describe "#call" do
    context "with valid params" do
      it "updates the book title" do
        command.call(book_id: book.id, title: "New Title")
        expect(book.reload.title).to eq("New Title")
      end

      it "broadcasts :book_updated" do
        event = nil
        command.on(:book_updated) { |e| event = e }
        command.call(book_id: book.id, title: "New Title")

        expect(event).to be_a(Catalog::Events::BookUpdated)
        expect(event.book_id).to eq(book.id)
        expect(event.title).to eq("New Title")
        expect(event.changes).to include("title")
      end

      it "logs a domain event" do
        expect {
          command.call(book_id: book.id, title: "New Title")
        }.to change(Shared::DomainEventLog, :count).by(1)
      end

      it "validates and normalizes ISBN when updated" do
        command.call(book_id: book.id, isbn: "978-0-13-468599-1")
        expect(book.reload.isbn).to eq("9780134685991")
      end
    end

    context "with invalid book_id" do
      it "broadcasts :update_book_failed" do
        errors = nil
        command.on(:update_book_failed) { |e| errors = e }
        command.call(book_id: "nonexistent", title: "X")

        expect(errors[:errors]).to include(match(/Book not found/))
      end
    end

    context "with invalid ISBN format" do
      it "broadcasts :update_book_failed" do
        errors = nil
        command.on(:update_book_failed) { |e| errors = e }
        command.call(book_id: book.id, isbn: "bad")

        expect(errors[:errors]).to include(match(/Invalid ISBN/))
      end
    end
  end
end
