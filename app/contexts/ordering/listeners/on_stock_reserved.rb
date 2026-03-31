module Ordering
  module Listeners
    class OnStockReserved < Shared::BaseListener
      def stock_reserved(event)
        log_received(:stock_reserved, event)

        order = Ordering::Order.find_by(id: event.order_id)
        return unless order&.pending?

        Ordering::Commands::ConfirmOrder.call(order_id: event.order_id)
      end
    end
  end
end
