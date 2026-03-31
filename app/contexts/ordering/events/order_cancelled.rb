module Ordering
  module Events
    OrderCancelled = Data.define(:order_id, :order_number, :line_items, :reason)
  end
end
