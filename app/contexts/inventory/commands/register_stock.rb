module Inventory
  module Commands
    class RegisterStock < Shared::BaseCommand
      def call(book_id:, quantity:)
        qty = Inventory::ValueObjects::Quantity.new(value: quantity)

        stock = Inventory::StockItem.find_or_initialize_by(book_id: book_id)
        stock.quantity_on_hand += qty.to_i
        stock.save!

        event = Inventory::Events::StockRegistered.new(
          book_id: book_id,
          quantity_added: qty.to_i,
          new_total: stock.quantity_on_hand
        )

        log_event(:stock_registered, event)
        broadcast(:stock_registered, event)
      rescue ArgumentError => e
        broadcast(:register_stock_failed, errors: [e.message])
      end
    end
  end
end
