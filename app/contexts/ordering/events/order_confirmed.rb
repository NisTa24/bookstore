module Ordering
  module Events
    OrderConfirmed = Data.define(:order_id, :order_number)
  end
end
