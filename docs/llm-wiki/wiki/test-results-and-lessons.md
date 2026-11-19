# Test Results and Lessons

Source: `tests/001-catalog.test.ts`, Vitest execution.

## Automated Test Evidence (Lab 0 / Baseline)
- **Framework**: Vitest v5.1.1 with Cloudflare Wrangler unstable_dev.
- **Suite**: `tests/001-catalog.test.ts`
  - Scenario 1: Book Catalog Retrieval (`GET /api/books`) -> **PASS (200 OK)**
  - Scenario 2: Category Filtering (`GET /api/books?category_id=1`) -> **PASS (200 OK)**
- **D1 Execution**:
  - `npx wrangler d1 execute bookstore-db --local --command "SELECT 1"` -> **PASS (Returned 1)**

## Lessons Learned
1. Cold start of `unstable_dev` requires a test timeout >= 10,000ms.
2. In-memory sqlite D1 must be initialized with local seed data before running catalog tests.
