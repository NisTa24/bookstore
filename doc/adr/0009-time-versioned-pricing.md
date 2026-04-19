# ADR-0009: Time-Versioned Pricing

**Date:** 2026-04-19
**Status:** Accepted

## Context

Book prices change over time — promotions start and end, publishers adjust MSRPs, and we may need to audit what price was effective at any given point. A simple "current price" column on the book record would overwrite history and make it impossible to answer questions like "what did this book cost last month?"

## Decision

Prices are modeled as **time-versioned records** in the `Pricing::Price` aggregate with `effective_from` and `effective_until` timestamps:

- Setting a new price automatically closes the previous price window by setting its `effective_until` to the new price's `effective_from`.
- The "current" price is the one where `effective_from <= now` and `effective_until IS NULL`.
- Price history is preserved indefinitely for audit and analytics.

### Schema
```
pricing_prices
  id           : string (UUID)
  book_id      : string (FK)
  amount_cents : integer
  currency     : string
  effective_from : datetime
  effective_until : datetime (nullable — NULL means "currently active")
```

## Consequences

### Positive
- Full price history is retained without any additional infrastructure.
- Temporal queries ("what was the price on date X?") are straightforward SQL.
- Supports future features like scheduled price changes or price rollback.

### Negative
- Querying the "current" price requires a WHERE clause on timestamps rather than a simple column read.
- The `SetBookPrice` command must atomically close the old price and open the new one to avoid windows where zero or two prices are active.
