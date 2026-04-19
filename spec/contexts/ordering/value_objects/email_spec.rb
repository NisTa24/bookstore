require "rails_helper"

RSpec.describe Ordering::ValueObjects::Email do
  describe "#initialize" do
    it "accepts a valid email" do
      email = described_class.new(value: "user@example.com")
      expect(email.value).to eq("user@example.com")
    end

    it "normalizes to lowercase" do
      email = described_class.new(value: "USER@EXAMPLE.COM")
      expect(email.value).to eq("user@example.com")
    end

    it "strips whitespace" do
      email = described_class.new(value: "  user@example.com  ")
      expect(email.value).to eq("user@example.com")
    end

    it "accepts emails with dots and hyphens" do
      email = described_class.new(value: "first.last@sub-domain.example.com")
      expect(email.value).to eq("first.last@sub-domain.example.com")
    end

    it "raises ArgumentError for invalid email" do
      expect { described_class.new(value: "not-an-email") }.to raise_error(ArgumentError, /Invalid email/)
    end

    it "raises ArgumentError for empty string" do
      expect { described_class.new(value: "") }.to raise_error(ArgumentError, /Invalid email/)
    end

    it "raises ArgumentError for email without domain" do
      expect { described_class.new(value: "user@") }.to raise_error(ArgumentError, /Invalid email/)
    end
  end

  describe "#to_s" do
    it "returns the normalized email" do
      email = described_class.new(value: "User@Example.COM")
      expect(email.to_s).to eq("user@example.com")
    end
  end

  describe "immutability" do
    it "is a frozen Data object" do
      email = described_class.new(value: "user@example.com")
      expect(email).to be_frozen
    end
  end
end
