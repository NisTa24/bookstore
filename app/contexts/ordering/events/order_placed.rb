module Ordering
  module Events
    OrderPlaced = Data.define(:order_id, :order_number, :customer_email,
                              :line_items, :total_amount_cents, :currency)
  end
end
