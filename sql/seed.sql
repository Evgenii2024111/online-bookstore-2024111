INSERT OR IGNORE INTO categories(id,name,slug) VALUES
  (1,'Database','database'),
  (2,'AI','ai'),
  (3,'Programming','programming');

INSERT OR IGNORE INTO books
(id,category_id,isbn,title,author,description,price_cents,stock) VALUES
(1,1,'9780000000011','SQL for Beginners','A. Smith','Learn relational databases and SQL fundamentals with practical exercises.',1999,3),
(2,1,'9780000000012','Database Design','B. Lee','Learn database normalization, primary keys, foreign keys, ER modeling, and transactions.',2499,2),
(3,2,'9780000000013','Introduction to AI','C. Kim','An accessible introduction to machine learning and artificial intelligence.',2299,5),
(4,2,'9780000000014','Practical RAG','D. Chen','Build semantic search systems with vector databases and large language models.',2999,4),
(5,3,'9780000000015','TypeScript Projects','E. Brown','Develop practical backend applications using TypeScript and APIs.',2099,5),
(6,1,'9780000000016','Distributed Data Systems','F. Park','Understand consistency, concurrency, transactions, and distributed database applications.',3499,1);

INSERT OR IGNORE INTO users(id,email,name) VALUES
(1,'student@university.edu','Evgenii Student'),
(2,'alice@example.com','Alice Johnson');
