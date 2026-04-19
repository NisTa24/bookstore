# ADR-0006: SQLite as Primary Database

**Date:** 2026-04-19
**Status:** Accepted

## Context

Rails 8 has embraced SQLite as a first-class production database, with Solid Cache and Solid Queue providing database-backed caching and job queuing without requiring Redis or a separate RDBMS.

We needed to choose a database that balances simplicity, operational cost, and the needs of our application.

## Decision

We use **SQLite3** as the primary database for all environments, supported by:
- **Solid Cache** for database-backed caching.
- **Solid Queue** for database-backed background job processing.

This aligns with Rails 8's "single-server, no-external-dependencies" deployment philosophy.

## Consequences

### Positive
- **Zero infrastructure overhead:** No database server to provision, monitor, or secure.
- **Simplified deployment:** The database is a single file, trivially backed up.
- **Rails 8 alignment:** Native support via Solid Cache and Solid Queue removes the need for Redis.
- **Fast for reads:** SQLite excels at read-heavy workloads on a single machine.

### Negative
- **Single-writer concurrency:** SQLite uses a single-writer lock, which limits write throughput under high concurrency. Our pessimistic locking strategy (ADR-0008) must account for this.
- **Not horizontally scalable:** Cannot run multiple application servers against the same SQLite database.
- **Limited to single-server deployment:** Suitable for small-to-medium scale only.

### Migration path
- The application uses standard ActiveRecord; switching to PostgreSQL requires only changing the `database.yml` configuration and the Gemfile adapter gem.
