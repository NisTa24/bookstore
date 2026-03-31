module Inventory
  module Commands
    class ReleaseStock < Shared::BaseCommand
      def call(order_id:, items:)
        items.each do |item|
          stock = Inventory::StockItem.find_by(book_id: item[:book_id])
          next unless stock

          stock.release!(item[:quantity])

          event = Inventory::Events::StockReleased.new(
            order_id: order_id,
            book_id: item[:book_id],
            quantity: item[:quantity]
          )

          log_event(:stock_released, event)
          broadcast(:stock_released, event)
        end
      end
    end
  end
end
