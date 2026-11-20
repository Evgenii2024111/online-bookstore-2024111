# Implementation Tasks: 001 - Catalog and Search

## Phase 1: Database Setup & Migrations
- [x] **TASK-001**: Create `migrations/0001_initial.sql` defining 6 common 3NF tables (`categories`, `books`, `users`, `orders`, `order_items`, `cart_items`) with CHECK, FK, and UNIQUE constraints.
- [x] **TASK-002**: Apply migration to local Cloudflare D1 database (`npx wrangler d1 migrations apply bookstore-db --local`).
- [x] **TASK-003**: Populate local D1 database with seed data in `sql/seed.sql` (`npx wrangler d1 execute bookstore-db --local --file sql/seed.sql`).

## Phase 2: API Endpoints Implementation (`src/index.ts`)
- [x] **TASK-004**: Implement `GET /api/categories` returning all category records.
- [x] **TASK-005**: Implement `GET /api/books` returning book catalog with optional `category_id` filter.
- [x] **TASK-006**: Implement `GET /api/books/:id` returning single book record or 404.
- [x] **TASK-007**: Implement `GET /api/books/search?q=` with:
  - Whitespace trimming (FR-SEARCH-06 / CHG-001)
  - 400 Bad Request on empty / whitespace-only query (AC-SEARCH-05)
  - Case-insensitive search across title or author (AC-SEARCH-01, AC-SEARCH-02)
  - Result limit capped at 10 (AC-SEARCH-04)
  - Empty array `[]` on no match (AC-SEARCH-03)

## Phase 3: Automated Testing & Verification
- [x] **TASK-008**: Implement Vitest test suite in `tests/001-catalog.test.ts` validating AC-SEARCH-01 through AC-SEARCH-06 and catalog endpoints.
- [x] **TASK-009**: Execute `npx vitest run` and verify all tests pass.
- [x] **TASK-010**: Verify SQL query behavior via `npx wrangler d1 execute bookstore-db --local`.

## Phase 4: Documentation & Wiki Ingestion
- [x] **TASK-011**: Record `CHG-001` in `docs/changes.md` and log AI prompt interactions in `docs/ai-prompt-log.md`.
- [x] **TASK-012**: Ingest snapshots into `docs/llm-wiki/raw/` and update wiki pages in `docs/llm-wiki/wiki/`.
