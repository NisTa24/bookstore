# Cross-context domain event wiring via Wisper
#
# This is the application's "wiring diagram" - the single place where
# bounded contexts are connected through domain events.
# Each subscription uses `scope:` to ensure listeners only fire
# for events from specific command classes.
#
# IMPORTANT: Subscription order matters! Read model updates should be
# registered BEFORE cross-context listeners, since the chain of events
# triggered by cross-context listeners may update those same read models.

Rails.application.config.after_initialize do
  # === Catalog Context Events ===

  # When a book is added, update the BookListing read model
  Wisper.subscribe(
    Catalog::Listeners::UpdateBookListing.new,
    scope: Catalog::Commands::AddBook
  )

  # When a book is updated, update the BookListing read model
  Wisper.subscribe(
    Catalog::Listeners::UpdateBookListing.new,
    scope: Catalog::Commands::UpdateBook
  )

  # When a book is retired, update the BookListing read model
  Wisper.subscribe(
    Catalog::Listeners::UpdateBookListing.new,
    scope: Catalog::Commands::RetireBook
  )

  # When a book is added to catalog, auto-create a default price
  Wisper.subscribe(
    Pricing::Listeners::OnBookAdded.new,
    scope: Catalog::Commands::AddBook
  )

  # === Ordering Context Events ===

  # Read model listeners FIRST (order matters with synchronous Wisper)
  # When an order is placed, create order summary read model
  Wisper.subscribe(
    Ordering::Listeners::UpdateOrderSummary.new,
    scope: Ordering::Commands::PlaceOrder
  )

  # When an order is confirmed, update order summary
  Wisper.subscribe(
    Ordering::Listeners::UpdateOrderSummary.new,
    scope: Ordering::Commands::ConfirmOrder
  )

  # When an order is cancelled, update order summary
  Wisper.subscribe(
    Ordering::Listeners::UpdateOrderSummary.new,
    scope: Ordering::Commands::CancelOrder
  )

  # Cross-context listeners AFTER read models
  # When an order is placed, reserve inventory
  Wisper.subscribe(
    Inventory::Listeners::OnOrderPlaced.new,
    scope: Ordering::Commands::PlaceOrder
  )

  # When an order is cancelled, release reserved stock
  Wisper.subscribe(
    Inventory::Listeners::OnOrderCancelled.new,
    scope: Ordering::Commands::CancelOrder
  )

  # === Inventory Context Events ===

  # When stock is reserved, confirm the order
  Wisper.subscribe(
    Ordering::Listeners::OnStockReserved.new,
    scope: Inventory::Commands::ReserveStock
  )

  # When stock is depleted, cancel the order
  Wisper.subscribe(
    Ordering::Listeners::OnStockDepleted.new,
    scope: Inventory::Commands::ReserveStock
  )
end
