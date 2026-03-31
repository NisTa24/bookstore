module Pricing
  module Commands
    class SetBookPrice < Shared::BaseCommand
      def call(book_id:, amount_cents:, currency: "USD", effective_from: Time.current)
        money = Pricing::ValueObjects::Money.new(
          amount_cents: amount_cents,
          currency: currency
        )

        # Expire the current price
        Pricing::Price
          .where(book_id: book_id, effective_until: nil)
          .update_all(effective_until: effective_from)

        price = Pricing::Price.create!(
          book_id: book_id,
          amount_cents: money.amount_cents,
          currency: money.currency,
          effective_from: effective_from
        )

        event = Pricing::Events::PriceSet.new(
          book_id: book_id,
          amount_cents: money.amount_cents,
          currency: money.currency,
          price_id: price.id
        )

        log_event(:price_set, event)
        broadcast(:price_set, event)
      rescue ArgumentError => e
        broadcast(:set_book_price_failed, errors: [e.message])
      end
    end
  end
end
