module Inventory
  module Listeners
    class OnOrderPlaced < Shared::BaseListener
      def order_placed(event)
        log_received(:order_placed, event)

        items = event.line_items.map do |li|
          { book_id: li[:book_id], quantity: li[:quantity] }
        end

        Inventory::Commands::ReserveStock.call(
          order_id: event.order_id,
          items: items
        )
      end
    end
  end
end
