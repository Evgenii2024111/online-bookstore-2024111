# Database & System Design Decisions

Source: `docs/llm-wiki/raw/database/0001_initial.sql`, `docs/llm-wiki/raw/specifications/001-catalog-search.md`, `specs/001-catalog-search/data-model.md`.

## 1. Relational Architecture & 3NF Normalization
The core database model consists of 6 relational tables designed in Third Normal Form (3NF) to eliminate data redundancy and preserve integrity across edge nodes:

1. **`categories`** (`id`, `name`, `slug`, `created_at`):
   - Stores catalog classification. Unique constraint on `name` prevents duplicate taxonomies.
2. **`books`** (`id`, `category_id`, `isbn`, `title`, `author`, `description`, `price_cents`, `stock`, `created_at`):
   - Stores book inventory. Foreign key references `categories(id)`.
   - `CHECK (stock >= 0)` guarantees inventory cannot be negative, preventing overselling.
   - `CHECK (price_cents >= 0)` prevents invalid negative pricing.
3. **`users`** (`id`, `email`, `name`, `created_at`):
   - Customer identity records with `email UNIQUE`.
4. **`orders`** (`id`, `user_id`, `request_key`, `total_cents`, `status`, `created_at`):
   - Purchase orders referencing `users(id)`.
   - `request_key UNIQUE` enforces request idempotency, preventing double-charging or duplicate checkout.
   - `CHECK (total_cents >= 0)` ensures non-negative totals.
5. **`order_items`** (`id`, `order_id`, `book_id`, `quantity`, `price_cents`):
   - Resolves the M:N relationship between Orders and Books.
   - Stores historical `price_cents` at the time of purchase to ensure auditability even if catalog prices change.
   - `ON DELETE CASCADE` on `order_id`.
6. **`cart_items`** (`id`, `user_id`, `book_id`, `quantity`, `created_at`):
   - Resolves the M:N relationship between Users and Books in cart.
   - Composite unique constraint `UNIQUE(user_id, book_id)` guarantees one row per user-book pair.

## 2. Currency Representation as Integer Cents
- **Decision**: Monetary values are strictly stored as integer cents (`price_cents`, `total_cents`).
- **Rationale**: Eliminates IEEE 754 floating-point rounding errors and decimal inaccuracies in SQL transactions and checkout operations.

## 3. Search Architecture: Parameterized SQL & FTS5
- **Decision**: Keyword search (`GET /api/books/search?q=`) uses parameterized SQL (`.bind(pattern, pattern)`) with case-insensitive `LOWER(title) LIKE ? OR LOWER(author) LIKE ?` and `LIMIT 10`.
- **Whitespace Trimming (CHG-001)**: Input queries are sanitized using `.trim()` prior to pattern creation, ensuring leading/trailing whitespace (`%20%20database%20%20`) produces identical results to canonical queries.
- **Full-Text Search (FTS5)**: A SQLite FTS5 virtual table `books_fts` with automated `AFTER INSERT`, `AFTER UPDATE`, and `AFTER DELETE` triggers provides content synchronization for full-text search.

## 4. Extension Architecture: University Textbook Store
- **Decision**: Model `courses` and `course_books` associative table.
- **Rationale**: General categories cannot express semester-specific course syllabi. Multiple courses require the same book, and one course requires multiple books. Resolved via composite PK `(course_id, book_id)` with `requirement_type` ('required' vs 'recommended').
- **Implementation Status**: Approved specification draft only; implementation is Not verified (deferred per Lab 1 scope).
