# Online Bookstore Constitution

## Core Principles

1. **Database integrity comes first.**
   Enforce schema constraints, relational integrity, primary keys, foreign keys (`PRAGMA foreign_keys = ON`), and check constraints (`stock >= 0`, `price_cents >= 0`) at the database level.

2. **Every feature has testable acceptance criteria.**
   No requirement is complete without clear, verifiable, and objective acceptance criteria (`AC-XXX-01`, etc.) defined before implementation begins.

3. **Use normalized relational schemas (3NF).**
   All entity models and tables must adhere to Third Normal Form (3NF) to eliminate redundancy and maintain consistency across domain records.

4. **Use parameterized SQL only.**
   Never concatenate untrusted input into raw SQL queries. Always bind parameters using SQLite/D1 prepared statements (`.bind(...)`).

5. **All purchases are atomic; no overselling, no duplicate orders.**
   Checkout and stock mutations must execute in atomic transactions. Enforce idempotency via unique request keys (`orders.request_key`).

6. **AI-generated code is accepted only with real test evidence.**
   Code and migrations generated or modified by AI must be proven by executing automated tests (`npx vitest run`) and running real local queries (`npx wrangler d1 execute`). Never fabricate test or execution logs.

7. **Specifications are living documents; record every change.**
   Every change discovered during testing or review must be formally recorded as a change entry (`CHG-xxx` in `docs/changes.md`) and reflected back in the specification before being implemented.

8. **Never use real payment information.**
   Use mock payment gateways, test credit cards, or simulated tokens. Real financial credentials or personal identifiable financial data are strictly forbidden.

## Operational & Architectural Governance

- **Runtime & Cloudflare Stack**: Cloudflare Workers, Cloudflare D1 (SQLite), Cloudflare Queues, Vectorize, and Supabase PostgreSQL.
- **Single-Writer Rule**:
  - `specs/` and `.specify/memory/`: Modified only upon student approval.
  - `src/`, `migrations/`, `tests/`: Modified only to fulfill approved tasks.
  - `docs/llm-wiki/raw/`: Read-only historical evidence.
  - `docs/llm-wiki/wiki/`: Managed per `docs/llm-wiki/WIKI-RULES.md`.
- **Secrets**: `.dev.vars` and sensitive tokens must remain git-ignored and never committed.

**Version**: 1.0.0 | **Ratified**: 2026-11-21 | **Project**: Online Bookstore Capstone (Student ID: 2024111)
