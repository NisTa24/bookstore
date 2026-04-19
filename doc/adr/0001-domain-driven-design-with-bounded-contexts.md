# ADR-0001: Domain-Driven Design with Bounded Contexts

**Date:** 2026-04-19
**Status:** Accepted

## Context

The bookstore domain spans several distinct business capabilities — managing a catalog of books, tracking inventory, processing orders, and handling pricing. A traditional Rails approach would co-locate all of this logic in a flat `app/models` directory, leading to tight coupling, god objects, and ambiguous ownership of business rules.

We needed an architecture that:
- Enforces clear boundaries between business capabilities.
- Allows each area of the domain to evolve independently.
- Makes the codebase navigable by aligning code structure with business language.

## Decision

We adopt **Domain-Driven Design (DDD)** and organize the application into explicit **bounded contexts** under `app/contexts/`:

| Context       | Responsibility                                   |
|---------------|--------------------------------------------------|
| **Catalog**   | Book metadata, authors, categories, ISBN handling |
| **Inventory** | Stock levels, reservation, and release            |
| **Ordering**  | Order lifecycle (place, confirm, cancel)          |
| **Pricing**   | Time-versioned prices and discount rules          |
| **Shared**    | Cross-cutting infrastructure (base classes, event log) |

Each context contains its own aggregates, commands, events, listeners, read models, and value objects — forming a self-contained module.

## Consequences

### Positive
- Business rules are co-located with the data they govern, making the system easier to reason about.
- Contexts can be extracted into separate services in the future with minimal refactoring.
- Teams can own individual contexts without stepping on each other.
- The Ubiquitous Language is preserved — a `Book` in Catalog is distinct from stock data in Inventory.

### Negative
- Higher initial complexity compared to vanilla Rails conventions.
- Cross-context queries require explicit integration (events or direct lookups) rather than simple ActiveRecord joins.
- Developers new to DDD face a learning curve.

### Risks
- Context boundaries may need to shift as the domain understanding deepens. Early mis-draws are costly to fix.
