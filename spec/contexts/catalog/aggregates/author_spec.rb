require "rails_helper"

RSpec.describe Catalog::Author, type: :model do
  describe "validations" do
    it "is valid with a name" do
      author = Catalog::Author.new(name: "Eric Evans")
      expect(author).to be_valid
    end

    it "is invalid without a name" do
      author = Catalog::Author.new(name: nil)
      expect(author).not_to be_valid
      expect(author.errors[:name]).to include("can't be blank")
    end
  end

  describe "#set_uuid" do
    it "generates a UUID on create" do
      author = Catalog::Author.create!(name: "Eric Evans")
      expect(author.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end
end
