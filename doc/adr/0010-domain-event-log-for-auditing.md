# ADR-0010: Domain Event Log for Auditing

**Date:** 2026-04-19
**Status:** Accepted

## Context

With an event-driven architecture, events are ephemeral — once delivered to listeners, they disappear. For debugging production issues, auditing business operations, and potentially replaying events to rebuild read models, we need a durable record of every event that occurred.

## Decision

All domain events are persisted to an **immutable `domain_events_log` table** via the `Shared::DomainEventLog` class:

### Schema
```
domain_events_log
  id          : string (UUID)
  event_type  : string (indexed)
  payload     : json
  occurred_at : datetime (indexed)
  created_at  : datetime
```

### Design principles
- **Append-only:** Events are never updated or deleted.
- **Self-describing:** The `event_type` field identifies the event, and the `payload` contains the full event data as JSON.
- **Indexed for queries:** Both `event_type` and `occurred_at` are indexed for efficient filtering and chronological browsing.
- **Exposed via API:** `GET /api/v1/events` allows inspecting recent events for debugging and monitoring.

## Consequences

### Positive
- Complete audit trail of all business operations.
- Enables debugging of complex event chains (e.g., why an order was auto-cancelled).
- Foundation for future event replay / read-model rebuilding.
- Useful for analytics and business intelligence.

### Negative
- Table grows indefinitely — will need a retention/archival policy at scale.
- JSON payloads are not schema-enforced at the database level.
- Not a replacement for a full event store if true event sourcing is adopted later.
