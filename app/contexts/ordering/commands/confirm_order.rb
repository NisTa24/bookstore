module Ordering
  module Commands
    class ConfirmOrder < Shared::BaseCommand
      def call(order_id:)
        order = Ordering::Order.find(order_id)

        unless order.pending?
          broadcast(:confirm_order_failed,
                    errors: ["Order #{order.order_number} is not pending"])
          return
        end

        order.confirm!

        event = Ordering::Events::OrderConfirmed.new(
          order_id: order.id,
          order_number: order.order_number
        )

        log_event(:order_confirmed, event)
        broadcast(:order_confirmed, event)
      rescue ActiveRecord::RecordNotFound
        broadcast(:confirm_order_failed, errors: ["Order not found: #{order_id}"])
      end
    end
  end
end
