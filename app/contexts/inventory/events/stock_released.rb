module Inventory
  module Events
    StockReleased = Data.define(:order_id, :book_id, :quantity)
  end
end
