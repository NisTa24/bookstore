module Inventory
  module Commands
    class ReserveStock < Shared::BaseCommand
      def call(order_id:, items:)
        reserved_items = []
        depleted_event = nil

        ActiveRecord::Base.transaction do
          items.each do |item|
            stock = Inventory::StockItem.find_by(book_id: item[:book_id])

            unless stock&.can_reserve?(item[:quantity])
              depleted_event = Inventory::Events::StockDepleted.new(
                order_id: order_id,
                book_id: item[:book_id],
                requested_quantity: item[:quantity],
                available_quantity: stock&.available_quantity || 0
              )
              raise ActiveRecord::Rollback
            end

            stock.reserve!(item[:quantity])
            reserved_items << item
          end
        end

        # Broadcast depleted event AFTER transaction rollback
        if depleted_event
          log_event(:stock_depleted, depleted_event)
          broadcast(:stock_depleted, depleted_event)
          return
        end

        # Only broadcast success if all items were reserved
        return if reserved_items.empty? && items.any?

        reserved_items.each do |item|
          event = Inventory::Events::StockReserved.new(
            order_id: order_id,
            book_id: item[:book_id],
            quantity: item[:quantity]
          )
          log_event(:stock_reserved, event)
          broadcast(:stock_reserved, event)
        end
      end
    end
  end
end
