# ADR-0007: Value Objects for Domain Validation

**Date:** 2026-04-19
**Status:** Accepted

## Context

Primitive types (strings, integers, floats) carry no semantic meaning or validation. Passing a raw string as an ISBN, email, or monetary amount means validation must be duplicated everywhere those values are used, and invalid data can silently propagate through the system.

## Decision

We implement **Value Objects** as plain Ruby classes to represent domain concepts that are defined by their attributes rather than identity:

| Value Object | Context   | Responsibility                                    |
|-------------|-----------|---------------------------------------------------|
| `ISBN`      | Catalog   | Validates and normalizes 10/13-digit ISBNs        |
| `Email`     | Ordering  | Validates RFC-compliant email, normalizes to lowercase |
| `Money`     | Pricing   | Immutable monetary arithmetic, enforces non-negative amounts |
| `Percentage`| Pricing   | Validates 0–100 range for discount calculations   |
| `Quantity`  | Inventory | Enforces positive integer quantities               |
| `OrderNumber` | Ordering | Generates unique, human-readable order identifiers |

### Design principles
- **Immutable:** Value objects do not change after construction. Operations return new instances.
- **Self-validating:** Invalid input raises `ArgumentError` at construction time — invalid values cannot exist.
- **Normalized:** Input is cleaned (e.g., stripped, downcased) during initialization.

## Consequences

### Positive
- Validation is centralized and guaranteed — if you have an `ISBN` instance, it is valid by definition.
- Business logic reads naturally: `price.apply_discount(percentage)` instead of manual arithmetic.
- Type safety without a static type system — method signatures communicate intent.

### Negative
- Additional classes for concepts that might feel "simple enough" as primitives.
- Serialization to/from the database requires explicit conversion at the aggregate boundary.
