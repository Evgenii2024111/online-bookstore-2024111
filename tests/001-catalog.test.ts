import { describe, it, expect, beforeAll } from 'vitest';
import { unstable_dev } from 'wrangler';
import type { UnstableDevWorker } from 'wrangler';

describe('Catalog Search API', () => {
  let worker: UnstableDevWorker;

  beforeAll(async () => {
    worker = await unstable_dev('src/index.ts', {
      experimental: { disableExperimentalWarning: true },
      config: 'wrangler.jsonc'
    });
  });

  it('Scenario 1: Book Catalog Retrieval', async () => {
    const res = await worker.fetch('/api/books');
    const data = await res.json();
    expect(res.status).toBe(200);
    expect(data).toHaveProperty('books');
  }, 10000);

  it('Scenario 2: Category Filtering', async () => {
    const res = await worker.fetch('/api/books?category_id=1');
    const data = await res.json();
    expect(res.status).toBe(200);
    if (data.books.length > 0) {
      expect(data.books.every((b: any) => b.category_id === 1)).toBe(true);
    }
  });
});
