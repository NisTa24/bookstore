# ADR-0008: Pessimistic Locking for Inventory Management

**Date:** 2026-04-19
**Status:** Accepted

## Context

The inventory system must prevent **overselling** — two concurrent orders must not both succeed if only one unit remains in stock. Optimistic locking (via `lock_version`) would detect conflicts after the fact and require retry logic. Given that stock reservation is a critical operation where correctness trumps throughput, we need a stronger guarantee.

## Decision

Stock mutations (`reserve!`, `release!`, `deduct!`) on the `Inventory::StockItem` aggregate use **pessimistic locking** via ActiveRecord's `with_lock`:

```ruby
def reserve!(quantity)
  with_lock do
    reload
    raise "Insufficient stock" if available < quantity
    update!(reserved: reserved + quantity)
  end
end
```

### Key details
- `with_lock` acquires a database-level row lock (`SELECT ... FOR UPDATE` on PostgreSQL; exclusive transaction lock on SQLite).
- `reload` inside the lock ensures we read the latest state, preventing stale-data bugs.
- The lock is held for the duration of the block and released when the transaction commits.

## Consequences

### Positive
- **Correctness guaranteed:** Concurrent reservations are serialized at the database level — overselling is impossible.
- **Simple implementation:** No retry loops, version columns, or conflict-resolution logic needed.
- **Transactional safety:** If any step within the lock fails, the entire transaction rolls back.

### Negative
- **Reduced concurrency:** Concurrent requests for the same stock item are serialized, creating a bottleneck under high contention.
- **Deadlock potential:** If multiple stock items are locked in different orders by concurrent transactions, deadlocks can occur. (Currently mitigated by reserving one item at a time.)
- **SQLite limitation:** SQLite's locking is database-wide rather than row-level, further constraining concurrent writes (see ADR-0006).

### Future considerations
- If write contention becomes a bottleneck, consider switching to PostgreSQL for true row-level locks, or adopting an optimistic locking strategy with retries.
