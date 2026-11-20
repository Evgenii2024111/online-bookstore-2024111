# Project Change Log

This file tracks all specification changes, discoveries made during testing, and architectural adjustments in accordance with Constitution Principle VII ("Specifications are living documents; record every change").

---

## CHG-001: Query Whitespace Trimming & Sanitization

- **Change ID**: CHG-001
- **Feature**: `001-catalog-search`
- **Date**: 2026-11-21
- **Author**: Student (ID: 2024111)
- **Status**: Approved & Implemented

### 1. Reason
During testing of the search endpoint with queries containing leading or trailing whitespace (`q=%20%20database%20%20`), the original specification did not define handling for extraneous whitespace. As a result, un-sanitized whitespace could alter pattern matching or cause whitespace-only queries to bypass empty-query validation.

### 2. Impact
- **Specification**:
  - Added `FR-SEARCH-06`: Trim leading and trailing whitespace from the search query before evaluation.
  - Added `AC-SEARCH-06`: Searching `"  database  "` returns the same results as searching `"database"`.
  - Refined `AC-SEARCH-05`: Queries consisting solely of whitespace characters must return HTTP 400 Bad Request.
- **Codebase (`src/index.ts`)**:
  - `const q = rawQ.trim().toLowerCase();`
  - Rejection if `rawQ === null || rawQ.trim() === ''`.
- **Database**: No migration required; search pattern sanitization handled in API layer.

### 3. New Test & Verification Evidence
- **Test Case**: `it('AC-SEARCH-06: "  database  " returns the same results as "database"')` in `tests/001-catalog.test.ts`.
- **Evidence**: Executed via `npx vitest run`. Test passed with HTTP 200 and identical JSON response. Whitespace-only query tested in `AC-SEARCH-05` returning HTTP 400.
