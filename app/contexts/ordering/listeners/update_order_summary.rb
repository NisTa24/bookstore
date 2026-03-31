module Ordering
  module Listeners
    class UpdateOrderSummary < Shared::BaseListener
      def order_placed(event)
        log_received(:order_placed, event)

        Ordering::ReadModels::OrderSummary.create!(
          order_id: event.order_id,
          order_number: event.order_number,
          customer_email: event.customer_email,
          status: "pending",
          total_amount_cents: event.total_amount_cents,
          currency: event.currency,
          item_count: event.line_items.size
        )
      end

      def order_confirmed(event)
        log_received(:order_confirmed, event)

        summary = Ordering::ReadModels::OrderSummary.find_by(order_id: event.order_id)
        summary&.update!(status: "confirmed")
      end

      def order_cancelled(event)
        log_received(:order_cancelled, event)

        summary = Ordering::ReadModels::OrderSummary.find_by(order_id: event.order_id)
        summary&.update!(status: "cancelled")
      end
    end
  end
end
