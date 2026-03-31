# Bookstore

A Domain-Driven Design (DDD) bookstore application built with Rails 8, demonstrating bounded contexts, CQRS, event-driven architecture, and the command pattern.

## Architecture

The application is organized into five bounded contexts that communicate through domain events via [Wisper](https://github.com/krisleech/wisper):

- **Catalog** -- Book, author, and category management with ISBN validation
- **Pricing** -- Price management with historical versioning and discount rules
- **Inventory** -- Stock tracking with reservation support and database-level locking
- **Ordering** -- Order processing with event-driven stock coordination
- **Shared** -- Base classes, domain event logging, and cross-cutting concerns

### Event Flow Example

```
PlaceOrder command
  │ broadcasts OrderPlaced
  ├─→ UpdateOrderSummary (creates read model)
  └─→ OnOrderPlaced (reserves inventory)
        │ ReserveStock command
        ├─→ StockReserved → OnStockReserved (confirms order)
        └─→ StockDepleted → OnStockDepleted (cancels order)
```

## Tech Stack

- Ruby 3.4.7
- Rails 8.1.2
- SQLite3
- Wisper (pub/sub domain events)
- Puma (web server)
- Solid Cache & Solid Queue (database-backed caching and jobs)
- Kamal (deployment)

## Getting Started

### Prerequisites

- Ruby 3.4.7

### Setup

```bash
bin/setup
```

This will install dependencies and set up the database.

### Running the Server

```bash
bin/rails server
```

## API Endpoints

All endpoints are under `/api/v1`.

### Books

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/books` | List all active books |
| GET | `/api/v1/books/:id` | Get a book |
| POST | `/api/v1/books` | Add a book |
| PATCH | `/api/v1/books/:id` | Update a book |
| DELETE | `/api/v1/books/:id` | Retire a book |

### Orders

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/orders` | List recent orders |
| GET | `/api/v1/orders/:id` | Get order details |
| POST | `/api/v1/orders` | Place an order |
| DELETE | `/api/v1/orders/:id` | Cancel an order |

### Inventory

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/inventory/:book_id` | View stock levels |
| POST | `/api/v1/inventory` | Register stock |

### Pricing

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/prices/:book_id` | Get current price |
| POST | `/api/v1/prices` | Set a price |

### Events

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/events` | List recent domain events |

## Project Structure

```
app/
├── contexts/
│   ├── catalog/          # Book catalog management
│   │   ├── aggregates/   # Book, Author, Category
│   │   ├── commands/     # AddBook, UpdateBook, RetireBook
│   │   ├── events/       # BookAdded, BookUpdated, BookRetired
│   │   ├── listeners/    # UpdateBookListing
│   │   ├── read_models/  # BookListing
│   │   └── value_objects/ # ISBN
│   ├── inventory/        # Stock tracking
│   │   ├── aggregates/   # StockItem
│   │   ├── commands/     # RegisterStock, ReserveStock, ReleaseStock
│   │   ├── events/       # StockRegistered, StockReserved, StockReleased, StockDepleted
│   │   ├── listeners/    # OnOrderPlaced, OnOrderCancelled
│   │   └── value_objects/ # Quantity
│   ├── ordering/         # Order processing
│   │   ├── aggregates/   # Order, OrderLine
│   │   ├── commands/     # PlaceOrder, ConfirmOrder, CancelOrder
│   │   ├── events/       # OrderPlaced, OrderConfirmed, OrderCancelled
│   │   ├── listeners/    # UpdateOrderSummary, OnStockReserved, OnStockDepleted
│   │   ├── read_models/  # OrderSummary
│   │   └── value_objects/ # Email, OrderNumber
│   ├── pricing/          # Price management
│   │   ├── aggregates/   # Price, DiscountRule
│   │   ├── commands/     # SetBookPrice, ApplyDiscount
│   │   ├── events/       # PriceSet, DiscountApplied
│   │   ├── listeners/    # OnBookAdded
│   │   └── value_objects/ # Money, Percentage
│   └── shared/           # Base classes and domain event log
└── controllers/api/v1/  # REST API controllers
```

## Deployment

The application includes a `Dockerfile` and is configured for deployment with [Kamal](https://kamal-deploy.org/).

```bash
kamal setup    # First-time deploy
kamal deploy   # Subsequent deploys
```
