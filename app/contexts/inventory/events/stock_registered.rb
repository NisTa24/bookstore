module Inventory
  module Events
    StockRegistered = Data.define(:book_id, :quantity_added, :new_total)
  end
end
