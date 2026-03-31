module Pricing
  module Events
    PriceSet = Data.define(:book_id, :amount_cents, :currency, :price_id)
  end
end
