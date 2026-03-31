module Pricing
  module Events
    DiscountApplied = Data.define(:book_id, :original_cents, :discounted_cents, :rule_name)
  end
end
