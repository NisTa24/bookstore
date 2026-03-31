module Inventory
  module Listeners
    class OnOrderCancelled < Shared::BaseListener
      def order_cancelled(event)
        log_received(:order_cancelled, event)

        Inventory::Commands::ReleaseStock.call(
          order_id: event.order_id,
          items: event.line_items
        )
      end
    end
  end
end
