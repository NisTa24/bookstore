# ADR-0005: UUID Primary Keys

**Date:** 2026-04-19
**Status:** Accepted

## Context

Auto-incrementing integer IDs are the Rails default. However, they leak information (e.g., total record count, creation order), create conflicts when merging data from multiple sources, and complicate future database sharding.

## Decision

All tables use **string-based UUIDs** as primary keys, configured globally in `config/application.rb`:

```ruby
config.generators do |g|
  g.orm :active_record, primary_key_type: :string
end
```

UUIDs are generated at the application level (via `SecureRandom.uuid`) before records are persisted.

## Consequences

### Positive
- **No information leakage:** External-facing IDs reveal nothing about record count or ordering.
- **Merge-safe:** Records from different environments or future shards will never collide.
- **Client-generated IDs:** IDs can be generated before a database round-trip, enabling optimistic patterns.

### Negative
- **Larger storage footprint:** String UUIDs (36 chars) use more space than integers (4–8 bytes), affecting index size.
- **Non-sequential:** Random UUIDs cause B-tree page splits on insert, which can degrade write performance at very high scale with traditional databases.
- **Less human-friendly:** UUIDs are harder to reference in conversation or logs than short integers.

### Mitigations
- SQLite (current database) is not significantly impacted by UUID index fragmentation at our scale.
- Human-friendly identifiers (e.g., `OrderNumber`) are used where readability matters.
