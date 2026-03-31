module Ordering
  module Listeners
    class OnStockDepleted < Shared::BaseListener
      def stock_depleted(event)
        log_received(:stock_depleted, event)

        Ordering::Commands::CancelOrder.call(
          order_id: event.order_id,
          reason: "Insufficient stock for book #{event.book_id}"
        )
      end
    end
  end
end
