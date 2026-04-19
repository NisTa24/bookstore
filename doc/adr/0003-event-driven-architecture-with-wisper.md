# ADR-0003: Event-Driven Architecture with Wisper

**Date:** 2026-04-19
**Status:** Accepted

## Context

Bounded contexts must communicate without creating direct dependencies. For example, when an order is placed, inventory must be reserved — but the Ordering context should not call Inventory code directly. We needed a mechanism that:
- Decouples producers from consumers.
- Allows multiple reactions to a single event.
- Keeps the wiring explicit and auditable.

## Decision

We use the **Wisper** gem (~3.0) to implement a **publish/subscribe event system**. Domain events are broadcast by commands, and listeners in other contexts subscribe to those events.

### Key design choices

1. **Synchronous delivery (in-process):** Events are delivered synchronously within the same request. This keeps the system simple and transactionally consistent without requiring a message broker.

2. **Scope-based subscriptions:** Each listener is bound to a specific command via Wisper's `scope:` parameter, preventing a listener from firing on unrelated events that share the same name.

3. **Centralized wiring in `config/initializers/wisper.rb`:** All subscriptions are declared in a single file, serving as the system's "wiring diagram." This makes the event flow discoverable.

4. **Subscription ordering matters:** Read-model listeners are subscribed **before** cross-context listeners to ensure read models are updated before downstream commands execute.

5. **Domain event log:** Every event is persisted to the `domain_events_log` table as an immutable JSON record for auditing and debugging.

### Event flow example (order placement)
```
PlaceOrder
  → order_placed
    → UpdateOrderSummary  (read model — subscribed first)
    → OnOrderPlaced       (triggers ReserveStock)
      → ReserveStock
        → stock_reserved → OnStockReserved → ConfirmOrder
        OR
        → stock_depleted → OnStockDepleted → CancelOrder
```

## Consequences

### Positive
- Contexts are loosely coupled — adding a new reaction to an event requires only a new listener and a subscription line.
- The centralized wiring file provides a single place to understand the full event flow.
- The domain event log provides a complete audit trail.

### Negative
- Synchronous delivery means a slow listener blocks the entire request.
- Deep event chains (order → reserve → confirm) can be hard to debug when something fails mid-chain.
- Moving to asynchronous delivery (e.g., via Solid Queue) in the future will require careful handling of transactional boundaries.

### Alternatives considered
- **ActiveSupport::Notifications:** Too low-level, no scoping support, designed for instrumentation rather than domain events.
- **External message broker (e.g., Kafka, RabbitMQ):** Overkill for the current scale; adds infrastructure complexity.
