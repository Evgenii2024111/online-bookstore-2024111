# Architecture & Implementation Plan: 001 - Catalog and Search

## 1. System Overview
Implementation of the Book Catalog and Book Search subsystem on Cloudflare Workers using Cloudflare D1 (SQLite engine) and Hono router.

## 2. Component Design

### 2.1 Database Layer (Cloudflare D1)
- Migration `migrations/0001_initial.sql` defining:
  - 6 relational tables: `categories`, `books`, `users`, `orders`, `order_items`, `cart_items`.
  - SQLite check constraints: `stock >= 0`, `price_cents >= 0`, `total_cents >= 0`, `quantity > 0`.
  - SQLite foreign key constraints with indexed foreign keys.
  - Idempotency unique constraint on `orders.request_key`.
- Seed data `sql/seed.sql`: Realistic books, categories, and test records.

### 2.2 HTTP Service Layer (`src/index.ts`)
- Uses Hono framework for light-weight routing on Cloudflare Workers runtime.
- Route Handlers:
  - `GET /api/categories`: Query `SELECT * FROM categories ORDER BY name ASC`.
  - `GET /api/books`: Query `books` joined with `categories`. Optional query parameter `category_id`.
  - `GET /api/books/:id`: Query book by primary key. Returns 404 `{ "error": "Book not found" }` if absent.
  - `GET /api/books/search?q={query}`:
    1. Parse and sanitize query string: trim leading/trailing whitespace.
    2. Check if trimmed query is empty; return HTTP 400 Bad Request with `{ "error": "Search query cannot be empty" }`.
    3. Execute parameterized SQL query:
       ```sql
       SELECT b.*, c.name as category_name
       FROM books b
       LEFT JOIN categories c ON b.category_id = c.id
       WHERE LOWER(b.title) LIKE ? OR LOWER(b.author) LIKE ?
       LIMIT 10;
       ```
       Passing `'%'+trimmed.toLowerCase()+'%'` as parameters.
    4. Return matching records or empty array `[]`.

### 2.3 Verification Strategy
- Local D1 migration: `npx wrangler d1 migrations apply bookstore-db --local`
- Local D1 seed: `npx wrangler d1 execute bookstore-db --local --file sql/seed.sql`
- Vitest automated suite in `tests/001-catalog.test.ts` covering AC-SEARCH-01 to AC-SEARCH-06 and catalog endpoints.
