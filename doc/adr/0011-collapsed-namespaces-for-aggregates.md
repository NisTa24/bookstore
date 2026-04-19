# ADR-0011: Collapsed Namespaces for Aggregates

**Date:** 2026-04-19
**Status:** Accepted

## Context

With DDD, aggregate classes live under `app/contexts/<context>/aggregates/`. Rails' autoloader would normally map `app/contexts/catalog/aggregates/book.rb` to `Catalog::Aggregates::Book`. The intermediate `Aggregates` module adds verbosity without value — in practice, you always want to write `Catalog::Book`, not `Catalog::Aggregates::Book`.

The same applies to other subdirectories: `commands`, `events`, `listeners`, `read_models`, and `value_objects`.

## Decision

We configure Rails' Zeitwerk autoloader to **collapse** the intermediate directories within each context, so that file paths do not generate intermediate namespace modules:

```ruby
# config/application.rb
%w[aggregates commands events listeners read_models value_objects].each do |subdir|
  Dir.glob(Rails.root.join("app/contexts/*/#{subdir}")).each do |path|
    config.autoload_paths << path
    Rails.autoloaders.main.collapse(path)
  end
end
```

### Result
| File path                                      | Class name         |
|------------------------------------------------|--------------------|
| `app/contexts/catalog/aggregates/book.rb`      | `Catalog::Book`    |
| `app/contexts/ordering/commands/place_order.rb` | `Ordering::PlaceOrder` |
| `app/contexts/pricing/value_objects/money.rb`  | `Pricing::Money`   |

## Consequences

### Positive
- Cleaner, more natural class names that match the Ubiquitous Language.
- Reduced verbosity throughout the codebase.
- File organization on disk still groups files by type (aggregates, commands, etc.) for discoverability.

### Negative
- If two files in different subdirectories of the same context have the same name, they will collide (e.g., `catalog/aggregates/book.rb` and `catalog/read_models/book.rb` would both try to define `Catalog::Book`). Mitigated by using distinct names for read models (e.g., `BookListing`).
