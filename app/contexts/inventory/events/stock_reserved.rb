module Inventory
  module Events
    StockReserved = Data.define(:order_id, :book_id, :quantity)
  end
end
