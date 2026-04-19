# ADR-0012: API-First Design with Versioned Namespace

**Date:** 2026-04-19
**Status:** Accepted

## Context

The bookstore needs to serve data to clients (web frontends, mobile apps, or third-party integrations). We needed to decide between server-rendered HTML views, a JSON API, or a hybrid approach — and how to handle API evolution.

## Decision

We adopt an **API-first design** with all primary endpoints under a versioned namespace:

```
/api/v1/books
/api/v1/orders
/api/v1/inventory
/api/v1/prices
/api/v1/events
```

Controllers inherit from `Api::V1::BaseController`, which provides shared concerns (JSON rendering, error handling).

Legacy HTML view controllers exist under `Catalog::` and `Inventory::` namespaces for basic web views but are secondary to the API.

## Consequences

### Positive
- **Client-agnostic:** Any frontend technology or external system can consume the API.
- **Versioning from day one:** The `/v1/` namespace allows introducing breaking changes in `/v2/` without disrupting existing clients.
- **Separation of concerns:** API controllers focus on serialization and HTTP semantics; business logic lives in commands.

### Negative
- Requires a separate frontend application (or Turbo/Hotwire) for the web UI.
- API versioning adds maintenance overhead when multiple versions coexist.
