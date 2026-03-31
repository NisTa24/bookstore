module Inventory
  module Events
    StockDepleted = Data.define(:order_id, :book_id, :requested_quantity, :available_quantity)
  end
end
