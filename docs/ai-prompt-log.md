# AI Prompt & SDD Interaction Log

This log documents AI agent invocations, skill usage, prompt inputs, and verification outcomes for the Online Bookstore capstone.

---

## Session 1 / Lab 1 — Spec-Anchored SDD & DB Design (2026-11-21)

### Entry 1: Constitution Creation
- **Skill**: `/skill speckit-constitution`
- **Prompt**:
  ```text
  Create the Online Bookstore constitution with the 8 core principles:
  1. Database integrity comes first.
  2. Every feature has testable acceptance criteria.
  3. Use normalized relational schemas (3NF).
  4. Use parameterized SQL only.
  5. All purchases are atomic; no overselling, no duplicate orders.
  6. AI-generated code is accepted only with real test evidence.
  7. Specifications are living documents; record every change.
  8. Never use real payment information.
  ```
- **Output Artifact**: `.specify/memory/constitution.md`
- **Result**: Approved. Principles codified.

### Entry 2: Feature Specification (Catalog & Search)
- **Skill**: `/skill speckit-specify`
- **Prompt**:
  ```text
  Feature: Book Catalog and Book Search.
  Customers can list books, view one book, and search books by title or author.
  Search is case-insensitive. Return at most 10 books.
  No match returns an empty list. Do not implement code yet.
  Write testable acceptance criteria: AC-SEARCH-01 through AC-SEARCH-05.
  ```
- **Output Artifact**: `specs/001-catalog-search/spec.md`
- **Result**: Approved.

### Entry 3: Architecture Planning & 3NF Data Model
- **Skill**: `/skill speckit-plan`
- **Prompt**:
  ```text
  Create plan.md and data-model.md covering the ERD of the 6 common tables in 3NF:
  categories, books, users, orders, order_items, cart_items.
  Cardinalities, constraints: CHECK (stock >= 0), UNIQUE (orders.request_key), integer price_cents, Orders <-> Books M:N through order_items.
  ```
- **Output Artifacts**: `specs/001-catalog-search/plan.md`, `specs/001-catalog-search/data-model.md`
- **Result**: Approved.

### Entry 4: Task Breakdown
- **Skill**: `/skill speckit-tasks`
- **Output Artifact**: `specs/001-catalog-search/tasks.md`
- **Result**: Approved tasks covering migrations, API, and tests.

### Entry 5: Implementation & Migration
- **Skill**: `/skill speckit-implement`
- **Actions**:
  - Generated `migrations/0001_initial.sql` for all 6 common tables and FTS5 search index.
  - Applied locally: `npx wrangler d1 migrations apply bookstore-db --local` (17 commands succeeded).
  - Seeded database: `npx wrangler d1 execute bookstore-db --local --file sql/seed.sql` (3 commands succeeded).
  - Implemented endpoints in `src/index.ts`: `GET /api/books`, `GET /api/books/:id`, `GET /api/books/search?q=`, `GET /api/categories`.
  - Created test suite: `tests/001-catalog.test.ts`.

### Entry 6: Feed-back Rule Discovery (CHG-001)
- **Discovery**: Query `q=%20%20database%20%20` revealed lack of whitespace specification.
- **Action**: Recorded `CHG-001` in `docs/changes.md`. Added `FR-SEARCH-06` and `AC-SEARCH-06` to `specs/001-catalog-search/spec.md`.
- **Code & Test Fix**: Added `.trim()` and `AC-SEARCH-06` test case.
- **Verification**: `npx vitest run` passed (9 passed).

### Entry 7: Extension Specification
- **Skill**: `/skill speckit-specify`
- **Prompt**:
  ```text
  Draft extension spec for University Textbook Store: specs/004-university-textbooks/spec.md.
  Draft ERD with courses and course_books. No code implementation.
  ```
- **Output Artifact**: `specs/004-university-textbooks/spec.md`
- **Result**: Approved.
