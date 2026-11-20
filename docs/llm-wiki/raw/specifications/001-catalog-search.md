# Feature Specification: 001 - Catalog and Search
Spec ID: SPEC-001
Status: Approved
Course Feature: CORE-01 (Book Catalog), CORE-02 (Book Search)

## 1. Feature Description
Book Catalog and Book Search.
Customers can list books, view one book, and search books by title or author. Search is case-insensitive, returns at most 10 books, and returns an empty list when no match is found.

## 2. User Stories
- **US-01 (Catalog Browsing)**: As a customer, I want to browse books and filter by category so that I can discover books of interest.
- **US-02 (Book Detail View)**: As a customer, I want to view details of a specific book by its ID so that I can see its full information and stock availability.
- **US-03 (Keyword Search)**: As a customer, I want to search books by title or author with case-insensitivity and automatic whitespace trimming so that I can easily find books even with messy input.
- **US-04 (Categories List)**: As a customer, I want to view all available categories so that I can navigate the store.

## 3. Endpoints
- `GET /api/books` - Retrieve all books (supports optional `?category_id=`).
- `GET /api/books/:id` - Retrieve a single book by ID (returns 404 if not found).
- `GET /api/books/search?q={query}` - Search books matching title or author (case-insensitive, max 10 results, trims whitespace).
- `GET /api/categories` - Retrieve list of all categories.

## 4. Functional Requirements
- **FR-SEARCH-01**: Retrieve list of books with category information.
- **FR-SEARCH-02**: Retrieve a single book by its numeric ID.
- **FR-SEARCH-03**: Case-insensitive substring/prefix search across `title` and `author`.
- **FR-SEARCH-04**: Limit search results to a maximum of 10 books.
- **FR-SEARCH-05**: Return an empty JSON array `[]` when no books match the query.
- **FR-SEARCH-06**: Trim leading and trailing whitespace from the search query before evaluation (introduced via CHG-001).
- **FR-SEARCH-07**: Empty search query (empty string or only whitespace) returns HTTP 400 Bad Request with an error message.

## 5. Acceptance Criteria
- **AC-SEARCH-01**: Searching `"database"` returns books whose title or author matches.
- **AC-SEARCH-02**: Searching `"DATABASE"` returns the same results as `"database"` (case-insensitive).
- **AC-SEARCH-03**: Searching `"unknown-book-xyz"` returns `[]`.
- **AC-SEARCH-04**: The search response never contains more than 10 books.
- **AC-SEARCH-05**: An empty query (`q=` or whitespace-only query) returns HTTP 400.
- **AC-SEARCH-06**: Searching with leading/trailing whitespace (`"  database  "`) returns the same results as `"database"`.
- **AC-CATALOG-01**: `GET /api/books` returns HTTP 200 with a list of books including `id`, `title`, `author`, `price_cents`, `stock`, `category_id`.
- **AC-CATALOG-02**: `GET /api/books/:id` returns HTTP 200 for an existing book, or HTTP 404 for a non-existent ID.
- **AC-CATALOG-03**: `GET /api/categories` returns HTTP 200 with all categories.

## 6. Verification
- Vitest automated tests in `tests/001-catalog.test.ts`.
- Local Cloudflare D1 queries via `npx wrangler d1 execute bookstore-db --local`.
