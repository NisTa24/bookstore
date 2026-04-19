require "rails_helper"

RSpec.describe Catalog::Commands::RetireBook do
  subject(:command) { described_class.new }

  let!(:book) { Catalog::Book.create(title: "To Retire", isbn: "9780306406157", status: "active") }

  describe "#call" do
    context "with valid book_id" do
      it "sets the book status to retired" do
        command.call(book_id: book.id)
        expect(book.reload.status).to eq("retired")
      end

      it "broadcasts :book_retired" do
        event = nil
        command.on(:book_retired) { |e| event = e }
        command.call(book_id: book.id)

        expect(event).to be_a(Catalog::Events::BookRetired)
        expect(event.book_id).to eq(book.id)
      end

      it "logs a domain event" do
        expect {
          command.call(book_id: book.id)
        }.to change(Shared::DomainEventLog, :count).by(1)
      end
    end

    context "with invalid book_id" do
      it "broadcasts :retire_book_failed" do
        errors = nil
        command.on(:retire_book_failed) { |e| errors = e }
        command.call(book_id: "nonexistent")

        expect(errors[:errors]).to include(match(/Book not found/))
      end
    end
  end
end
