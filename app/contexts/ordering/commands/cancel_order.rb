module Ordering
  module Commands
    class CancelOrder < Shared::BaseCommand
      def call(order_id:, reason: "Cancelled by customer")
        order = Ordering::Order.find(order_id)

        unless order.pending? || order.confirmed?
          broadcast(:cancel_order_failed,
                    errors: ["Order #{order.order_number} cannot be cancelled"])
          return
        end

        line_items = order.order_lines.map do |ol|
          { book_id: ol.book_id, quantity: ol.quantity }
        end

        order.cancel!

        event = Ordering::Events::OrderCancelled.new(
          order_id: order.id,
          order_number: order.order_number,
          line_items: line_items,
          reason: reason
        )

        log_event(:order_cancelled, event)
        broadcast(:order_cancelled, event)
      rescue ActiveRecord::RecordNotFound
        broadcast(:cancel_order_failed, errors: ["Order not found: #{order_id}"])
      end
    end
  end
end
