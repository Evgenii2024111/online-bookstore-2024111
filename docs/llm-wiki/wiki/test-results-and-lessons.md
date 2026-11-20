# Test Results and Lessons

Source: `docs/llm-wiki/raw/tests/001-catalog-search-test.log`, `tests/001-catalog.test.ts`, `docs/changes.md`.

## 1. Verified Automated Test Evidence (Lab 1)
- **Framework**: Vitest v5.1.1 running on Node.js v22.20.0 with Cloudflare Wrangler `unstable_dev`.
- **Target Suite**: `tests/001-catalog.test.ts`
- **Execution Date**: 2026-11-21
- **Status**: **PASS (9 tests passed, 0 failed)**
- **Total Duration**: 17.32s (Worker startup & initial connection ~14.7s; API requests 6ms - 46ms).

### Acceptance Criteria Verification Table

| Test Case | Method / Endpoint | Input / Condition | Expected Behavior | Actual Result | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AC-CATALOG-01** | `GET /api/books` | None | Returns HTTP 200 with non-empty `books` array | HTTP 200, array of books returned | **PASS** |
| **AC-CATALOG-02** | `GET /api/books/:id` | Valid ID (`/1`) vs Non-existent (`/999999`) | HTTP 200 with book details; HTTP 404 for invalid | HTTP 200 for ID 1; HTTP 404 for ID 999999 | **PASS** |
| **AC-CATALOG-03** | `GET /api/categories` | None | Returns HTTP 200 with category list | HTTP 200, category list returned | **PASS** |
| **AC-SEARCH-01** | `GET /api/books/search?q=database` | Query `"database"` | Returns books matching title, author, or description | HTTP 200, matching books returned | **PASS** |
| **AC-SEARCH-02** | `GET /api/books/search?q=DATABASE` | Query `"DATABASE"` (uppercase) | Returns identical results as lowercase query | HTTP 200, identical results to AC-SEARCH-01 | **PASS** |
| **AC-SEARCH-03** | `GET /api/books/search?q=unknown-book-xyz` | Non-existent keyword | Returns HTTP 200 with empty array `[]` | HTTP 200, returns `[]` | **PASS** |
| **AC-SEARCH-04** | `GET /api/books/search?q=a` | Broad query | Response contains at most 10 books | HTTP 200, result length <= 10 | **PASS** |
| **AC-SEARCH-05** | `GET /api/books/search?q=` | Empty string & whitespace-only (`%20%20%20`) | Returns HTTP 400 Bad Request | HTTP 400 Bad Request | **PASS** |
| **AC-SEARCH-06** | `GET /api/books/search?q=%20%20database%20%20` | Query with leading & trailing whitespace | Returns identical results as `"database"` | HTTP 200, matches AC-SEARCH-01 exactly | **PASS** |

### Local D1 Database Verification Evidence
- `npx wrangler d1 migrations apply bookstore-db --local`: 17 commands executed successfully (Migration `0001_initial.sql`).
- `npx wrangler d1 execute bookstore-db --local --file sql/seed.sql`: 3 commands executed successfully.
- `npx wrangler d1 execute bookstore-db --local --command "SELECT 1"`: Returns `1`.

---

## 2. Defects, Feed-back Loop & Lessons Learned

### Lesson 1: Spec Feed-back Discovery (CHG-001)
- **Defect**: During exploratory testing with `q=%20%20database%20%20`, the original specification did not specify whitespace trimming.
- **SDD Resolution**: Per Constitution Principle VII, code was not altered immediately. A change record (`CHG-001` in `docs/changes.md`) was logged, `FR-SEARCH-06` and `AC-SEARCH-06` were added to `specs/001-catalog-search/spec.md`, and only then was `.trim()` implemented and verified via automated test.

### Lesson 2: Local Worker Startup Latency in CI/Tests
- **Issue**: `unstable_dev` local server initialization and binding initialization takes 8–14 seconds on cold start on macOS. Default 5,000ms test timeout caused initial test timeout.
- **Fix**: Configured test timeout to 20,000ms for the initial request, ensuring stable test execution across test runs.

### Lesson 3: Extension Verification Boundary
- Remote deployment and live production checkout remain **Not verified** (deliberately out of scope for Lab 1).
