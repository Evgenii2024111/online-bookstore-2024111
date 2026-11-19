# Database Design Decisions

Source: `sql/schema.sql`, `migrations/`, `docs/llm-wiki/raw/proposal.md`.

## Relational Architecture
- **Primary Operational DB**: Cloudflare D1 (SQLite at the edge) for ultra-low latency reads.
- **Relational Backend**: Supabase PostgreSQL for persistent relational storage and advanced analytics.

## Schema Entities
1. **categories**: `id`, `name`, `slug`
2. **books**: `id`, `title`, `author`, `isbn`, `price`, `stock`, `category_id`
3. **books_fts**: SQLite FTS5 full-text index on title, author, and description.
4. **courses** (Extension): `id`, `code`, `name`, `term`
5. **course_books** (Extension): Composite key `(course_id, book_id)`, foreign keys with `ON DELETE CASCADE`.

## Invariants & Constraints
- Composite primary key on `(course_id, book_id)` guarantees no duplicate book assignments per course.
- Stock count must remain non-negative (`stock >= 0`).
