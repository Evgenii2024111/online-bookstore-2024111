# Architecture and API

Source: `src/index.ts`, `wrangler.jsonc`.

## Tech Stack
- **Compute**: Cloudflare Workers (TypeScript / ES modules)
- **Database**: Cloudflare D1 (`bookstore-db`) & Supabase PostgreSQL
- **Search**: D1 FTS5 (BM25) & Vectorize (Embeddings)
- **Queues**: Cloudflare Queues for asynchronous order/notification jobs

## API Endpoints
- `GET /api/health` — Worker health and status check
- `GET /api/books` — Catalog list with optional `?category_id=` filtering
- `GET /api/fts?q=` — Full-text keyword search across books
- `GET /api/courses/:code/books` — (Planned Extension) Course textbook lookup
