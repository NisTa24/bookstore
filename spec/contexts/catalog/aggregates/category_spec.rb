require "rails_helper"

RSpec.describe Catalog::Category, type: :model do
  describe "validations" do
    it "is valid with name and slug" do
      category = Catalog::Category.new(name: "Fiction", slug: "fiction")
      expect(category).to be_valid
    end

    it "is invalid without a name" do
      category = Catalog::Category.new(name: nil, slug: "fiction")
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a slug" do
      category = Catalog::Category.new(name: "Fiction", slug: nil)
      expect(category).not_to be_valid
      expect(category.errors[:slug]).to include("can't be blank")
    end

    it "enforces slug uniqueness" do
      Catalog::Category.create(name: "Fiction", slug: "fiction")
      duplicate = Catalog::Category.new(name: "Fiction 2", slug: "fiction")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include("has already been taken")
    end
  end

  describe "#set_uuid" do
    it "generates a UUID on create" do
      category = Catalog::Category.create(name: "Fiction", slug: "fiction")
      expect(category.id).to match(/\A[0-9a-f-]{36}\z/)
    end
  end
end
