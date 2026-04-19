require "rails_helper"

RSpec.describe Catalog::Book, type: :model do
  def build_book(overrides = {})
    Catalog::Book.new({
      title: "Domain-Driven Design",
      isbn: "9780321125217",
      status: "active"
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with title, isbn, and status" do
      book = build_book
      expect(book).to be_valid
    end

    it "is invalid without a title" do
      book = build_book(title: nil)
      expect(book).not_to be_valid
      expect(book.errors[:title]).to include("can't be blank")
    end

    it "is invalid without an isbn" do
      book = build_book(isbn: nil)
      expect(book).not_to be_valid
      expect(book.errors[:isbn]).to include("can't be blank")
    end

    it "enforces isbn uniqueness" do
      build_book.save!
      duplicate = build_book(title: "Another Book")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:isbn]).to include("has already been taken")
    end

    it "is invalid with unknown status" do
      book = build_book(status: "unknown")
      expect(book).not_to be_valid
      expect(book.errors[:status]).to include("is not included in the list")
    end

    it "accepts active status" do
      book = build_book(status: "active")
      expect(book).to be_valid
    end

    it "accepts retired status" do
      book = build_book(status: "retired")
      expect(book).to be_valid
    end
  end

  describe "associations" do
    it "optionally belongs to an author" do
      book = build_book(author_id: nil)
      expect(book).to be_valid
    end

    it "optionally belongs to a category" do
      book = build_book(category_id: nil)
      expect(book).to be_valid
    end
  end

  describe "#set_uuid" do
    it "generates a UUID on create" do
      book = build_book
      book.save!
      expect(book.id).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
    end
  end

  describe "#retire!" do
    it "sets status to retired" do
      book = build_book
      book.save!
      book.retire!
      expect(book.reload.status).to eq("retired")
    end
  end

  describe "#active?" do
    it "returns true when status is active" do
      book = build_book(status: "active")
      expect(book.active?).to be true
    end

    it "returns false when status is retired" do
      book = build_book(status: "retired")
      expect(book.active?).to be false
    end
  end

  describe ".active scope" do
    it "returns only active books" do
      active = build_book(isbn: "9780306406157")
      active.save!
      retired = build_book(isbn: "0306406152", status: "retired")
      retired.save!

      expect(Catalog::Book.active).to include(active)
      expect(Catalog::Book.active).not_to include(retired)
    end
  end
end
