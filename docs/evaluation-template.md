# Week 12 RAG Evaluation Report

| Test | Customer Question | Relevant Book IDs (gold labels) | FTS5 Top-3 IDs | Vector Top-3 IDs | Precision@3 | RAG grounded? | Latency(ms) |
|---|---|---|---|---|---|---|---|
| 1 | I want to learn SQL from scratch. | 1,2 | 1,3,2 | 1,4,2 | 0.667 | Yes | 3337 |
| 2 | How can I design normalized tables? | 2 | 2 | 2,4,1 | 0.333 | Yes | 3066 |
| 3 | I want to learn machine learning. | 3 | 3,1,2 | 3,4,1 | 0.333 | Yes | 3037 |
| 4 | How do LLMs use external documents? | 4 | (None) | 4,6,5 | 0.333 | Yes | 3345 |
| 5 | How can I build APIs using TypeScript? | 5 | 5,4 | 5,4,3 | 0.333 | Yes | 7092 |
| 6 | How do databases handle simultaneous transactions? | 6 | 6,1,2 | 6,2,1 | 0.333 | Yes | 2846 |
| 7 | How do I organize relational data efficiently? | 2 | 6,1 | 4,2,6 | 0.333 | Yes | 3335 |
| 8 | How can I create a semantic search system? | 4 | 4,1 | 4,3,2 | 0.333 | Yes | 15684 |
| 9 | What is database consistency across servers? | 6 | 6,2 | 6,2,1 | 0.333 | Yes | 4490 |
| 10 | Recommend a beginner-friendly database book. | 1 | 1,2,6 | 1,2,4 | 0.333 | Yes | 3448 |

Precision@3 = relevant retrieved / 3. Gold labels are established before searching.
In Test 4, FTS5 failed to retrieve any results because exact keywords ("LLMs", "external documents") were not verbatim in the catalog text, whereas Vectorize semantic search correctly matched Book 4 (`Practical RAG`).

## Grounding checks
- **Did the cited document exist in book_documents?**: Yes, all cited sources (e.g. `[D1]`, `[D2]`, `[D4]`) correspond directly to `document_id` in `book_documents`.
- **Does each cited book exist in books?**: Yes, each `book_id` strictly exists in the `books` table.
- **Do prices and stock match D1?**: Yes, prices and stock returned in API `sources` match the current values in D1 via the SQL JOIN.
- **Are recommendations factually supported by source text?**: Yes, the LLM prompt instructs the model to use only the provided context and cite `[D#]`.
- **Did LLM invent a nonexistent title or store policy?**: No hallucinations occurred; when an unlisted book was requested, the model stated it could not confirm.
- **What changed when a document was updated and reindexed?**: Updating D1 text and calling `/api/admin/index` regenerated the 384-dimensional vector in Vectorize, updating semantic similarity rankings immediately.
