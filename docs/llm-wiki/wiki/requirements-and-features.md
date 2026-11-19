# Requirements and Features

Source: `specs/` (Specs in repository are the approved source of truth).

## Common Core Features (CORE-01 to CORE-09)
- **CORE-01**: Book catalog retrieval with pagination and category filtering (`GET /api/books`).
- **CORE-02**: Keyword & full-text search (BM25 with D1 FTS5, `GET /api/fts`).
- **CORE-03**: Semantic vector search (Cloudflare Vectorize + Workers AI).
- **CORE-04**: Shopping cart management.
- **CORE-05**: Order processing with concurrency protection.
- **CORE-06**: User authentication and session management.
- **CORE-07**: Background tasks via Cloudflare Queues.
- **CORE-08**: Hybrid database replication (Cloudflare D1 + Supabase PostgreSQL).
- **CORE-09**: Edge caching and performance optimization.

## Individual Extension
- **University Textbook Store**:
  - Course-to-textbook syllabus mapping (`M:N` relational model).
  - Many-to-many lookup: `courses` and `course_books`.
  - Atomic purchase and duplicate prevention.
