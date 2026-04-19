# ADR-0002: CQRS with Read Models

**Date:** 2026-04-19
**Status:** Accepted

## Context

Queries for the book catalog and order history require data that spans multiple aggregates (e.g., a book listing needs the book title, author name, category, current price, and stock count). Fetching this through normalized aggregate tables would require complex multi-table joins on every request, coupling the read path to the write-side schema.

## Decision

We adopt **Command Query Responsibility Segregation (CQRS)**:

- **Write side:** All state mutations flow through **Command** objects (e.g., `AddBook`, `PlaceOrder`) that operate on aggregates and emit domain events.
- **Read side:** Denormalized **Read Models** (e.g., `Catalog::BookListing`, `Ordering::OrderSummary`) are maintained by event listeners and serve queries directly.

Read models are stored in dedicated database tables (`catalog_book_listings`, `ordering_order_summaries`) and are kept in sync by listeners that react to domain events.

### Write path
```
Controller → Command → Aggregate → Event → Listener → Read Model update
```

### Read path
```
Controller → Read Model → JSON response
```

## Consequences

### Positive
- API queries are fast — single-table reads with no joins.
- Read and write schemas can evolve independently.
- Read models are tailored to specific UI/API needs.

### Negative
- Data in read models is **eventually consistent** with the write side (though currently synchronous via Wisper).
- Read model tables must be rebuilt if their structure changes or if events are replayed.
- Duplication of data between aggregates and read models increases storage.
