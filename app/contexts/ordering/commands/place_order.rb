module Ordering
  module Commands
    class PlaceOrder < Shared::BaseCommand
      def call(customer_email:, items:)
        email = Ordering::ValueObjects::Email.new(value: customer_email)
        order_number = Ordering::ValueObjects::OrderNumber.new

        # Look up current prices for each book (cross-context query)
        line_items_data = items.map do |item|
          price = Pricing::Price.current_for_book(item[:book_id]).first
          unless price
            broadcast(:place_order_failed,
                      errors: ["No price found for book #{item[:book_id]}"])
            return
          end

          {
            book_id: item[:book_id],
            quantity: item[:quantity],
            unit_price_cents: price.amount_cents,
            unit_price_currency: price.currency
          }
        end

        total = line_items_data.sum { |li| li[:unit_price_cents] * li[:quantity] }

        order = nil
        ActiveRecord::Base.transaction do
          order = Ordering::Order.create!(
            order_number: order_number.to_s,
            customer_email: email.to_s,
            status: "pending",
            total_amount_cents: total,
            total_currency: "USD"
          )

          line_items_data.each do |li|
            Ordering::OrderLine.create!(
              order_id: order.id,
              book_id: li[:book_id],
              quantity: li[:quantity],
              unit_price_cents: li[:unit_price_cents],
              unit_price_currency: li[:unit_price_currency]
            )
          end
        end

        event = Ordering::Events::OrderPlaced.new(
          order_id: order.id,
          order_number: order.order_number,
          customer_email: order.customer_email,
          line_items: line_items_data,
          total_amount_cents: total,
          currency: "USD"
        )

        log_event(:order_placed, event)
        broadcast(:order_placed, event)
      rescue ArgumentError => e
        broadcast(:place_order_failed, errors: [e.message])
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:place_order_failed, errors: e.record.errors.full_messages)
      end
    end
  end
end
