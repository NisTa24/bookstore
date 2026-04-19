# ADR-0004: Command Pattern for All Write Operations

**Date:** 2026-04-19
**Status:** Accepted

## Context

In standard Rails, business logic often lives in controllers or models, making it difficult to test, reuse, or compose. We needed a consistent entry point for all state-mutating operations that:
- Encapsulates business logic in a testable unit.
- Integrates naturally with the event system.
- Provides a uniform interface for controllers.

## Decision

All write operations are implemented as **Command** objects that inherit from `Shared::BaseCommand`. Commands:

1. Accept input parameters.
2. Validate preconditions.
3. Execute the business operation (creating/updating aggregates).
4. Broadcast success or failure events via Wisper.

### Examples

| Command               | Context   | Events emitted                     |
|-----------------------|-----------|------------------------------------|
| `Catalog::AddBook`    | Catalog   | `book_added` / `book_add_failed`   |
| `Ordering::PlaceOrder`| Ordering  | `order_placed` / `order_place_failed` |
| `Inventory::ReserveStock` | Inventory | `stock_reserved` / `stock_depleted` |
| `Pricing::SetBookPrice` | Pricing | `price_set` / `price_set_failed`   |

### Controller interaction pattern
```ruby
command = Catalog::AddBook.new(params)
command.on(:book_added)      { |book| render json: book, status: :created }
command.on(:book_add_failed) { |errors| render json: { errors: }, status: :unprocessable_entity }
command.call
```

## Consequences

### Positive
- Business logic is isolated from HTTP concerns and easily unit-testable.
- Commands are composable — listeners can invoke other commands to create workflows.
- The success/failure event pattern gives controllers a clean, callback-based interface.
- Every write operation is automatically visible in the event log.

### Negative
- More files and indirection compared to "fat model" or "fat controller" Rails conventions.
- Simple CRUD operations feel over-engineered when wrapped in a command.
