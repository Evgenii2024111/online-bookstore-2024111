# Feature Specification: 001 - Catalog and Search
Spec ID: SPEC-001
Status: Draft (Awaiting Student Approval)
Course Feature: CORE-01 (Book Catalog), CORE-02 (Book Search)

## 1. Objective
Establish the foundational relational catalog and search APIs using Cloudflare D1 and FTS5 full-text search, supporting category filtering, stock visibility, and high-performance keyword queries.

## 2. User Scenarios & Acceptance Criteria

### Scenario 1: Book Catalog Retrieval
- **Given** the bookstore has categories and books populated in D1
- **When** a client sends `GET /api/books`
- **Then** the API returns HTTP 200 with an array of books containing `id`, `isbn`, `title`, `author`, `description`, `price_cents`, `stock`, and `category_name`.

### Scenario 2: Category Filtering
- **Given** categories `Database`, `AI`, and `Programming` exist
- **When** a client sends `GET /api/books?category_id=1`
- **Then** only books belonging to category 1 are returned.

### Scenario 3: Full-Text Search
- **Given** books exist with titles and descriptions
- **When** a client sends `GET /api/fts?q={query}`
- **Then** the API queries `books_fts` using bm25 scoring and returns the top matching books.

### Scenario 4: Automated Index Synchronization
- **Given** an existing book record
- **When** its title, author, or description is updated in `books`
- **Then** D1 database triggers update `books_fts` automatically without manual reindexing.

## 3. Data Model Constraints
- `categories.id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `categories.name`: TEXT NOT NULL UNIQUE
- `books.id`: INTEGER PRIMARY KEY AUTOINCREMENT
- `books.category_id`: INTEGER NOT NULL REFERENCES categories(id)
- `books.price_cents`: INTEGER NOT NULL CHECK (price_cents >= 0)
- `books.stock`: INTEGER NOT NULL CHECK (stock >= 0)
- `books_fts`: SQLite FTS5 virtual table with content sync triggers (`AFTER INSERT`, `AFTER UPDATE`, `AFTER DELETE`)

## 4. Verification Method
- Local D1 query verification via `npx wrangler d1 execute bookstore-db --local`
- Automated test suite verification via `npx vitest run`
