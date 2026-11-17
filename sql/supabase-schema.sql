-- ====================================================================
-- Online Bookstore — Supabase PostgreSQL Schema & Seed Data
-- ====================================================================

-- 1. Enable Extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Categories
CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

-- 3. Books Catalog
CREATE TABLE IF NOT EXISTS books (
  id SERIAL PRIMARY KEY,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  isbn TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  description TEXT NOT NULL,
  price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
  stock INTEGER NOT NULL CHECK (stock >= 0)
);
CREATE INDEX IF NOT EXISTS idx_books_category ON books(category_id);

-- 4. Book Documents (for RAG & pgvector)
CREATE TABLE IF NOT EXISTS book_documents (
  document_id SERIAL PRIMARY KEY,
  book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL DEFAULT 'catalog',
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(384),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_book_documents_book ON book_documents(book_id);

-- 5. Customers
CREATE TABLE IF NOT EXISTS customers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Orders
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  book_id INTEGER NOT NULL REFERENCES books(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  status TEXT NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Payments
CREATE TABLE IF NOT EXISTS payments (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents >= 0),
  status TEXT NOT NULL DEFAULT 'COMPLETED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Shipments
CREATE TABLE IF NOT EXISTS shipments (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  tracking_number TEXT,
  status TEXT NOT NULL DEFAULT 'PROCESSING',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. Notifications
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  message TEXT NOT NULL,
  sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ====================================================================
-- Initial Seed Data
-- ====================================================================

INSERT INTO categories (id, name) VALUES
  (1, 'Database'),
  (2, 'AI'),
  (3, 'Programming')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));

INSERT INTO books (id, category_id, isbn, title, author, description, price_cents, stock) VALUES
  (1, 1, '9780000000011', 'SQL for Beginners', 'A. Smith', 'Learn relational databases and SQL fundamentals with practical exercises.', 1999, 3),
  (2, 1, '9780000000012', 'Database Design', 'B. Lee', 'Learn database normalization, primary keys, foreign keys, ER modeling, and transactions.', 2499, 2),
  (3, 2, '9780000000013', 'Introduction to AI', 'C. Kim', 'An accessible introduction to machine learning and artificial intelligence.', 2299, 5),
  (4, 2, '9780000000014', 'Practical RAG', 'D. Chen', 'Build semantic search systems with vector databases and large language models.', 2999, 4),
  (5, 3, '9780000000015', 'TypeScript Projects', 'E. Brown', 'Develop practical backend applications using TypeScript and APIs.', 2099, 5),
  (6, 1, '9780000000016', 'Distributed Data Systems', 'F. Park', 'Understand consistency, concurrency, transactions, and distributed database applications.', 3499, 1)
ON CONFLICT (id) DO UPDATE SET
  category_id = EXCLUDED.category_id,
  isbn = EXCLUDED.isbn,
  title = EXCLUDED.title,
  author = EXCLUDED.author,
  description = EXCLUDED.description,
  price_cents = EXCLUDED.price_cents,
  stock = EXCLUDED.stock;

SELECT setval('books_id_seq', (SELECT MAX(id) FROM books));

INSERT INTO book_documents (document_id, book_id, doc_type, title, content)
SELECT id, id, 'catalog', title, description FROM books
ON CONFLICT (document_id) DO UPDATE SET
  title = EXCLUDED.title,
  content = EXCLUDED.content;

SELECT setval('book_documents_document_id_seq', (SELECT MAX(document_id) FROM book_documents));

INSERT INTO customers (id, name, email) VALUES
  (1, 'Alice Test', 'alice@example.com'),
  (2, 'Bob Student', 'bob@example.com')
ON CONFLICT (id) DO NOTHING;

SELECT setval('customers_id_seq', (SELECT MAX(id) FROM customers));
