# Week 12: Online Bookstore — Vectorize + D1 + RAG

## Lesson relationship
Week 10: FTS5 → Week 11: embeddings and manual cosine search → Week 12: Vectorize and RAG → Week 15: production capstone.
This is a classroom demonstration, not a production-ready bookstore.

## 0. Install

```bash
npm install
node -v
npx wrangler login
```

## 1. Cloud services (create once, reuse existing resources)

```bash
npx wrangler d1 list
npx wrangler d1 create w12-rag-db
npx wrangler vectorize create w12-rag-vectors --dimensions=384 --metric=cosine
```

Configured in `wrangler.jsonc` with database ID `b57259e0-5e2b-4d3b-a9b7-1f70be406028` and index `w12-rag-vectors`.

**Deployed Worker URL:** `https://online-bookstore.2024111.workers.dev`

**WARNING: This project uses `remote:true` for D1. The next commands MODIFY your actual remote D1 database. Use a dedicated student database, never a database with real orders.**

## 2. SQL (one-time or idempotent initialization)

```bash
npx wrangler d1 execute w12-rag-db --remote --file=./sql/schema.sql
npx wrangler d1 execute w12-rag-db --remote --file=./sql/seed.sql
npx wrangler d1 execute w12-rag-db --remote --file=./sql/rag.sql
npx wrangler d1 execute w12-rag-db --remote --command="SELECT id,title,stock FROM books;"
npx wrangler d1 execute w12-rag-db --remote --command="SELECT document_id,book_id,title FROM book_documents;"
```

If upgrading an existing Week 11/15 project with other tables, inspect the schema and run ONLY the missing SQL statements; do not overwrite a production schema.

## 3. Set secrets

```bash
cp .dev.vars.example .dev.vars
```

Edit both tokens to unrelated long values. Never add `.dev.vars` to Git.

## 4. Run and index

```bash
npm run types
npm run typecheck
npm run dev
```

Open another terminal:

```bash
export DEMO_TOKEN='the-token-from-.dev.vars'
export ADMIN_TOKEN='the-other-token-from-.dev.vars'
curl http://localhost:8787/api/health
curl http://localhost:8787/api/books
curl http://localhost:8787/api/documents
curl -X POST http://localhost:8787/api/admin/index -H "Authorization: Bearer $ADMIN_TOKEN"
```

Vectorize indexing is asynchronous; search may return zero results immediately after upsert. Try again after indexing has propagated.

```bash
curl -G http://localhost:8787/api/fts -H "Authorization: Bearer $DEMO_TOKEN" --data-urlencode "q=database"
curl -G http://localhost:8787/api/semantic -H "Authorization: Bearer $DEMO_TOKEN" --data-urlencode "q=I want to learn SQL from scratch"
curl -G http://localhost:8787/api/recommend -H "Authorization: Bearer $DEMO_TOKEN" --data-urlencode "q=Recommend an easy database book and tell me the price and stock"
```

Open http://localhost:8787 to try the browser interface. Only enter `DEMO_TOKEN`, never the admin token.

## 5. Data freshness lab

```bash
npx wrangler d1 execute bookstore-db --remote --command="UPDATE books SET price_cents=2599,stock=1 WHERE id=1;"
```

Search again: price and stock now come from D1 without recomputing embeddings. If editing book text, also update its `book_documents` content, then POST `/api/admin/index` to rebuild vectors. For deleted documents remove their corresponding vector IDs using `env.VECTORIZE.deleteByIds(["doc:1"])` in a secured admin operation or use Wrangler's vectorize delete-vectors command.

## 6. Optional deployment

```bash
npx wrangler secret put DEMO_TOKEN
npx wrangler secret put ADMIN_TOKEN
npm run deploy
```

This public classroom demo uses bearer tokens but lacks user accounts, per-user authorization and rate limiting. Turn it off after class.


## Compatibility with the earlier Vectorize-only Week 12 lab

The earlier Vectorize-only file uses IDs such as `"1"` for book vectors. This RAG document-based lab uses `"doc:1"`, etc. If the same `bookstore-vectors` index has legacy IDs, they may occupy Top-K results and get skipped by the RAG lookup. For a dedicated classroom index that contains only your earlier sample book IDs, delete those six older IDs before indexing:

```bash
npx wrangler vectorize delete-vectors bookstore-vectors --ids 1 2 3 4 5 6
```

**Only delete vectors that you own; never run this on a shared or production index.** Alternatively create a new, dedicated 384D cosine index and change `index_name` accordingly. Vectorize changes can take a few seconds to become queryable.

If FTS5 is added to a database where book rows already exist, an explicit one-time rebuild may be required:

```bash
npx wrangler d1 execute bookstore-db --remote --command="INSERT INTO books_fts(books_fts) VALUES('rebuild');"
```

## 7. Model choices

Embeddings: `@cf/baai/bge-small-en-v1.5` (384D). Generation: `@cf/meta/llama-3.3-70b-instruct-fp8-fast` (currently documented and higher-cost than the lesson's fp8 model). The uploaded RAG material uses `@cf/meta/llama-3.1-8b-instruct-fp8`, which has a documented planned deprecation on November 20, 2026. Inspect Cloudflare's model catalog before instruction, and adjust `GENERATION_MODEL` if needed. All Workers AI usage is subject to limits and pricing.

## 8. Assignment

Run 10 queries. Log expected relevant Book IDs, Top-3, Precision@3, latency, and any unsupported LLM claim. Submit README, SQL, TypeScript, screenshots, evaluation and system diagram.
