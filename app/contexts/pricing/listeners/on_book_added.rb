module Pricing
  module Listeners
    class OnBookAdded < Shared::BaseListener
      DEFAULT_PRICE_CENTS = 999 # $9.99

      def book_added(event)
        log_received(:book_added, event)

        Pricing::Commands::SetBookPrice.call(
          book_id: event.book_id,
          amount_cents: DEFAULT_PRICE_CENTS,
          currency: "USD"
        )
      end
    end
  end
end
