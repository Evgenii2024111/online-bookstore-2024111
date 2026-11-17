CREATE TABLE IF NOT EXISTS book_documents (
  document_id INTEGER PRIMARY KEY,
  book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL DEFAULT 'catalog',
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_book_documents_book ON book_documents(book_id);
INSERT OR IGNORE INTO book_documents(document_id,book_id,doc_type,title,content)
SELECT id,id,'catalog',title,description FROM books WHERE id BETWEEN 1 AND 6;
