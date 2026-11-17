PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS books (
  id INTEGER PRIMARY KEY,
  category_id INTEGER NOT NULL REFERENCES categories(id),
  isbn TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  description TEXT NOT NULL,
  price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
  stock INTEGER NOT NULL CHECK (stock >= 0)
);
CREATE INDEX IF NOT EXISTS idx_books_category ON books(category_id);
CREATE VIRTUAL TABLE IF NOT EXISTS books_fts USING fts5(
  title, author, description, content='books', content_rowid='id'
);
CREATE TRIGGER IF NOT EXISTS books_ai AFTER INSERT ON books BEGIN
  INSERT INTO books_fts(rowid,title,author,description)
  VALUES(new.id,new.title,new.author,new.description);
END;
CREATE TRIGGER IF NOT EXISTS books_ad AFTER DELETE ON books BEGIN
  INSERT INTO books_fts(books_fts,rowid,title,author,description)
  VALUES('delete',old.id,old.title,old.author,old.description);
END;
CREATE TRIGGER IF NOT EXISTS books_au AFTER UPDATE OF title, author, description ON books BEGIN
  INSERT INTO books_fts(books_fts,rowid,title,author,description)
  VALUES('delete',old.id,old.title,old.author,old.description);
  INSERT INTO books_fts(rowid,title,author,description)
  VALUES(new.id,new.title,new.author,new.description);
END;
