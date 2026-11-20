# Wiki Log

Append-only audit trail of ingestions, queries, and knowledge updates.

## 2026-11-18 — Initial Wiki Setup (Lab 0)
- Ingested: `docs/llm-wiki/raw/proposal.md`
- Established initial wiki structure following Karpathy Wiki specification.
- Verified OpenClaw agent `bookstore`, Telegram bot `@evgenii_bookstore_bot`, Spec Kit generic skills, and Cloudflare D1 local connection.


## 2026-11-21 — Lab 1: First Spec, 3NF DB Design & Search Feed-back Loop
- **Ingested**:
  - `docs/llm-wiki/raw/specifications/001-catalog-search.md`: Approved feature specification snapshot with AC-SEARCH-01 through AC-SEARCH-06.
  - `docs/llm-wiki/raw/database/0001_initial.sql`: 6 common tables in 3NF (`categories`, `books`, `users`, `orders`, `order_items`, `cart_items`) with CHECK, FK, and UNIQUE constraints.
  - `docs/llm-wiki/raw/tests/001-catalog-search-test.log`: Execution evidence for 9 automated Vitest test cases (all passed).
- **Updated Pages**:
  - `docs/llm-wiki/wiki/design-decisions.md`: Documented 3NF rationale, integer cents, constraints, parameterized search, and extension design.
  - `docs/llm-wiki/wiki/test-results-and-lessons.md`: Added verification table for AC-SEARCH-01 through AC-SEARCH-06 and lessons learned from CHG-001.
  - `docs/llm-wiki/wiki/index.md`: Updated topic index with [[design-decisions]].
- **Git Commit Target**: Session 1 / Lab 1 completion.
