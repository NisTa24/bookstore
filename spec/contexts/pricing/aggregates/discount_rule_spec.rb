require "rails_helper"

RSpec.describe Pricing::DiscountRule, type: :model do
  let(:book_id) { SecureRandom.uuid }

  def create_rule(overrides = {})
    Pricing::DiscountRule.create({
      name: "Summer Sale",
      discount_type: "percentage",
      value: 10,
      active: true,
      valid_from: 1.day.ago
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with all required attributes" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "percentage", value: 10, valid_from: Time.current)
      expect(rule).to be_valid
    end

    it "is invalid without name" do
      rule = Pricing::DiscountRule.new(name: nil, discount_type: "percentage", value: 10, valid_from: Time.current)
      expect(rule).not_to be_valid
    end

    it "is invalid with unknown discount_type" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "bogus", value: 10, valid_from: Time.current)
      expect(rule).not_to be_valid
    end

    it "accepts percentage discount_type" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "percentage", value: 10, valid_from: Time.current)
      expect(rule).to be_valid
    end

    it "accepts fixed_amount discount_type" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "fixed_amount", value: 500, valid_from: Time.current)
      expect(rule).to be_valid
    end

    it "is invalid with zero value" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "percentage", value: 0, valid_from: Time.current)
      expect(rule).not_to be_valid
    end

    it "is invalid with negative value" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "percentage", value: -5, valid_from: Time.current)
      expect(rule).not_to be_valid
    end

    it "is invalid without valid_from" do
      rule = Pricing::DiscountRule.new(name: "Sale", discount_type: "percentage", value: 10, valid_from: nil)
      expect(rule).not_to be_valid
    end
  end

  describe ".active scope" do
    it "returns only active rules" do
      active_rule = create_rule(active: true)
      create_rule(active: false, name: "Inactive")

      expect(Pricing::DiscountRule.active).to include(active_rule)
      expect(Pricing::DiscountRule.active.count).to eq(1)
    end
  end

  describe ".applicable_to scope" do
    it "returns rules matching a specific book" do
      rule = create_rule(book_id: book_id)
      result = Pricing::DiscountRule.applicable_to(book_id, nil)
      expect(result).to include(rule)
    end

    it "returns global rules (no book_id or category_id)" do
      rule = create_rule(book_id: nil, category_id: nil)
      result = Pricing::DiscountRule.applicable_to(book_id, nil)
      expect(result).to include(rule)
    end

    it "excludes expired rules" do
      create_rule(valid_from: 3.days.ago, valid_until: 1.day.ago)
      result = Pricing::DiscountRule.applicable_to(book_id, nil)
      expect(result).to be_empty
    end

    it "excludes inactive rules" do
      create_rule(active: false)
      result = Pricing::DiscountRule.applicable_to(book_id, nil)
      expect(result).to be_empty
    end
  end
end
