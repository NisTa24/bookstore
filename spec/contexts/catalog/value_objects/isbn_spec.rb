require "rails_helper"

RSpec.describe Catalog::ValueObjects::ISBN do
  describe "#initialize" do
    it "accepts a valid ISBN-13" do
      isbn = described_class.new(value: "9780306406157")
      expect(isbn.value).to eq("9780306406157")
    end

    it "accepts a valid ISBN-10" do
      isbn = described_class.new(value: "0306406152")
      expect(isbn.value).to eq("0306406152")
    end

    it "accepts ISBN-10 ending with X" do
      isbn = described_class.new(value: "080442957X")
      expect(isbn.value).to eq("080442957X")
    end

    it "normalizes by removing hyphens" do
      isbn = described_class.new(value: "978-0-306-40615-7")
      expect(isbn.value).to eq("9780306406157")
    end

    it "normalizes by removing spaces" do
      isbn = described_class.new(value: "978 0 306 40615 7")
      expect(isbn.value).to eq("9780306406157")
    end

    it "raises ArgumentError for invalid ISBN" do
      expect { described_class.new(value: "123") }.to raise_error(ArgumentError, /Invalid ISBN/)
    end

    it "raises ArgumentError for empty string" do
      expect { described_class.new(value: "") }.to raise_error(ArgumentError, /Invalid ISBN/)
    end

    it "raises ArgumentError for alphabetic string" do
      expect { described_class.new(value: "abcdefghijk") }.to raise_error(ArgumentError, /Invalid ISBN/)
    end
  end

  describe "#to_s" do
    it "returns the normalized value" do
      isbn = described_class.new(value: "978-0306406157")
      expect(isbn.to_s).to eq("9780306406157")
    end
  end

  describe "#isbn_13?" do
    it "returns true for ISBN-13" do
      isbn = described_class.new(value: "9780306406157")
      expect(isbn.isbn_13?).to be true
    end

    it "returns false for ISBN-10" do
      isbn = described_class.new(value: "0306406152")
      expect(isbn.isbn_13?).to be false
    end
  end

  describe "immutability" do
    it "is a frozen Data object" do
      isbn = described_class.new(value: "9780306406157")
      expect(isbn).to be_frozen
    end
  end
end
