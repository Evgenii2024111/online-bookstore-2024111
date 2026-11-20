import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { unstable_dev } from 'wrangler';
import type { UnstableDevWorker } from 'wrangler';

describe('Catalog & Search API Tests (SPEC-001)', () => {
  let worker: UnstableDevWorker;

  beforeAll(async () => {
    worker = await unstable_dev('src/index.ts', {
      experimental: { disableExperimentalWarning: true },
      config: 'wrangler.jsonc'
    });
  }, 30000);

  afterAll(async () => {
    if (worker) {
      await worker.stop();
    }
  });

  // AC-CATALOG-01
  it('AC-CATALOG-01: GET /api/books returns book catalog', async () => {
    const res = await worker.fetch('/api/books');
    expect(res.status).toBe(200);
    const data = (await res.json()) as { books: any[] };
    expect(data).toHaveProperty('books');
    expect(Array.isArray(data.books)).toBe(true);
    expect(data.books.length).toBeGreaterThan(0);
  }, 20000);

  // AC-CATALOG-02
  it('AC-CATALOG-02: GET /api/books/:id returns single book or 404', async () => {
    const resOk = await worker.fetch('/api/books/1');
    expect(resOk.status).toBe(200);
    const book = (await resOk.json()) as any;
    expect(book).toHaveProperty('id', 1);
    expect(book).toHaveProperty('title');
    expect(book).toHaveProperty('price_cents');

    const res404 = await worker.fetch('/api/books/999999');
    expect(res404.status).toBe(404);
  });

  // AC-CATALOG-03
  it('AC-CATALOG-03: GET /api/categories returns category list', async () => {
    const res = await worker.fetch('/api/categories');
    expect(res.status).toBe(200);
    const data = await res.json();
    const categories = Array.isArray(data) ? data : (data as any).categories;
    expect(Array.isArray(categories)).toBe(true);
    expect(categories.length).toBeGreaterThan(0);
  });

  // AC-SEARCH-01
  it('AC-SEARCH-01: Searching "database" returns books whose title or author matches', async () => {
    const res = await worker.fetch('/api/books/search?q=database');
    expect(res.status).toBe(200);
    const books = (await res.json()) as any[];
    expect(Array.isArray(books)).toBe(true);
    expect(books.length).toBeGreaterThan(0);
    for (const b of books) {
      const match =
        b.title.toLowerCase().includes('database') ||
        b.author.toLowerCase().includes('database') ||
        (b.description && b.description.toLowerCase().includes('database'));
      expect(match).toBe(true);
    }
  });

  // AC-SEARCH-02
  it('AC-SEARCH-02: Searching "DATABASE" returns the same results (case-insensitive)', async () => {
    const resLower = await worker.fetch('/api/books/search?q=database');
    const resUpper = await worker.fetch('/api/books/search?q=DATABASE');
    expect(resUpper.status).toBe(200);
    const lowerBooks = await resLower.json();
    const upperBooks = await resUpper.json();
    expect(upperBooks).toEqual(lowerBooks);
  });

  // AC-SEARCH-03
  it('AC-SEARCH-03: Searching "unknown-book-xyz" returns []', async () => {
    const res = await worker.fetch('/api/books/search?q=unknown-book-xyz');
    expect(res.status).toBe(200);
    const books = await res.json();
    expect(books).toEqual([]);
  });

  // AC-SEARCH-04
  it('AC-SEARCH-04: The response never contains more than 10 books', async () => {
    const res = await worker.fetch('/api/books/search?q=a');
    expect(res.status).toBe(200);
    const books = (await res.json()) as any[];
    expect(Array.isArray(books)).toBe(true);
    expect(books.length).toBeLessThanOrEqual(10);
  });

  // AC-SEARCH-05
  it('AC-SEARCH-05: An empty query returns HTTP 400', async () => {
    const resEmpty = await worker.fetch('/api/books/search?q=');
    expect(resEmpty.status).toBe(400);

    const resSpaces = await worker.fetch('/api/books/search?q=%20%20%20');
    expect(resSpaces.status).toBe(400);
  });

  // AC-SEARCH-06 (Step 7 / CHG-001)
  it('AC-SEARCH-06: "  database  " returns the same results as "database"', async () => {
    const resNormal = await worker.fetch('/api/books/search?q=database');
    const resPadded = await worker.fetch('/api/books/search?q=%20%20database%20%20');
    expect(resPadded.status).toBe(200);
    const normalBooks = await resNormal.json();
    const paddedBooks = await resPadded.json();
    expect(paddedBooks).toEqual(normalBooks);
  });
});
