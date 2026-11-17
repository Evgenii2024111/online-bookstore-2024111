# Online Bookstore Capstone Proposal — Review 1

**Student ID**: 2024111  
**Project**: Online Bookstore Capstone with Agile SDD  
**Architecture**: Cloudflare Workers, D1, Queues, Vectorize, Supabase PostgreSQL, OpenClaw Agent

---

## 1. Problem to Solve & Target Users

### Problem
Traditional university and technical bookstores struggle with dynamic stock management during course registration surges, semantic search across domain-specific literature, and concurrency collisions when multiple students simultaneously purchase limited inventory.

### Target Users
- **University Students & Faculty**: Seeking required textbooks, syllabus reading lists, and course-specific study resources.
- **Independent Developers**: Searching for specialized technical literature using natural language queries (e.g. "books teaching relational transactions") rather than exact ISBNs.

---

## 2. Individual Extension: University Textbook Store

### Extension Description
Extends the core bookstore catalog by mapping academic courses (e.g., `CS101`, `CS204`) directly to required and recommended textbook literature in a Many-to-Many (`M:N`) relational model.

### Candidate Tables
```sql
CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,       -- e.g., 'CS101'
  name TEXT NOT NULL,              -- e.g., 'Database Systems'
  term TEXT NOT NULL               -- e.g., 'Fall 2026'
);

CREATE TABLE course_books (
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
  is_required BOOLEAN NOT NULL DEFAULT true,
  PRIMARY KEY (course_id, book_id)
);
CREATE INDEX idx_course_books_course ON course_books(course_id);
```

### Verifiable Data Invariants
1. A book cannot be assigned to the same course more than once (enforced by composite primary key `(course_id, book_id)`).
2. Deleting a course cleanly cascades to remove course-book mappings without corrupting the book catalog.

---

## 3. User Story & Acceptance Criteria

### User Story
> **As a** student enrolled in a university course (`CS101`),  
> **I want to** look up my course code and see all assigned textbooks along with live stock and prices,  
> **So that** I can purchase my required syllabus materials before the semester begins without purchasing duplicates.

### Acceptance Criteria (Verifiable via SQL & API)
- **AC-1 (Course Syllabus Lookup)**:
  `GET /api/courses/CS101/books` returns HTTP 200 with all books linked via `course_books JOIN books`, returning title, author, price, stock, and whether the item is `is_required`.
- **AC-2 (Duplicate Prevention)**:
  Attempting to insert a duplicate `(course_id, book_id)` mapping in D1 / Supabase fails with a `UNIQUE constraint failed / duplicate key` error.
- **AC-3 (Atomic Course Purchase)**:
  Purchasing an in-stock required textbook decrements stock in `books` atomically within a transaction and creates an order record linked to the customer.

---

## 4. Out of Scope (What this project will NOT build)
1. **Third-Party Payment Gateways**: No live credit card charge APIs (Stripe, PayPal, Apple Pay). All payment flows use simulated tokens.
2. **Physical Shipping Integration**: No real-world carrier tracking APIs (FedEx, UPS, DHL).
3. **Complex User Roles**: No multi-tenant university administration dashboards or instructor grading portals.

---

## 5. Development Environment & SDD Status
- **Agent**: OpenClaw `bookstore` agent mapped to `/Users/ser/Desktop/bookstore`.
- **SDD Skills**: `skills/bookstore-sdd/SKILL.md`, GitHub Spec Kit generic skills.
- **Databases**: Cloudflare D1 (`bookstore-db`), Supabase PostgreSQL.
- **Skills**: `bookstore-sdd`, `karpathy-wiki`, `speckit-*` suite (`speckit-specify`, `speckit-plan`, `speckit-tasks`, `speckit-implement`, `speckit-converge`).
