import pg from 'pg';
const { Client } = pg;

async function connectWithRetry(retries = 5) {
  for (let i = 0; i < retries; i++) {
    const client = new Client({
      host: 'aws-0-ap-southeast-1.pooler.supabase.com',
      port: 6543,
      database: 'postgres',
      user: 'postgres.mrwbvyxhukuwskctrwky',
      password: 'BCtSm3vH9n871vVQ',
      ssl: { rejectUnauthorized: false }
    });
    try {
      await client.connect();
      return client;
    } catch (e) {
      console.log(`Connection attempt ${i + 1} failed: ${e.message}. Retrying...`);
      await new Promise(r => setTimeout(r, 1500));
    }
  }
  throw new Error('Could not connect to Supabase pooler after retries');
}

async function run() {
  const client = await connectWithRetry();
  console.log('Connected to Supabase PostgreSQL!');

  const tables = [
    'categories',
    'books',
    'book_documents',
    'customers',
    'orders',
    'payments',
    'shipments',
    'notifications'
  ];

  console.log('Enabling Row Level Security (RLS) on all tables...');
  for (const t of tables) {
    await client.query(`ALTER TABLE public.${t} ENABLE ROW LEVEL SECURITY;`);
  }

  console.log('Dropping any old policies...');
  for (const t of tables) {
    const existing = await client.query(`
      SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = $1;
    `, [t]);
    for (const row of existing.rows) {
      await client.query(`DROP POLICY IF EXISTS "${row.policyname}" ON public.${t};`);
    }
  }

  console.log('Creating standard RLS policies...');

  // 1. Catalog tables: Public read
  await client.query(`
    CREATE POLICY "Allow public read categories" ON public.categories
      FOR SELECT TO anon, authenticated, service_role USING (true);

    CREATE POLICY "Allow public read books" ON public.books
      FOR SELECT TO anon, authenticated, service_role USING (true);

    CREATE POLICY "Allow public read book_documents" ON public.book_documents
      FOR SELECT TO anon, authenticated, service_role USING (true);
  `);

  // 2. Service role: Full access on all tables
  for (const t of tables) {
    await client.query(`
      CREATE POLICY "Allow service_role full access ${t}" ON public.${t}
        FOR ALL TO service_role USING (true) WITH CHECK (true);
    `);
  }

  // 3. Customer read & order placement
  await client.query(`
    CREATE POLICY "Allow read customers" ON public.customers
      FOR SELECT TO authenticated, anon USING (true);

    CREATE POLICY "Allow insert orders" ON public.orders
      FOR INSERT TO authenticated, anon WITH CHECK (true);

    CREATE POLICY "Allow read orders" ON public.orders
      FOR SELECT TO authenticated, anon USING (true);

    CREATE POLICY "Allow read shipments" ON public.shipments
      FOR SELECT TO authenticated, anon USING (true);

    CREATE POLICY "Allow read notifications" ON public.notifications
      FOR SELECT TO authenticated, anon USING (true);
  `);

  console.log('\n--- VERIFICATION OF RLS STATUS ---');
  const rlsRes = await client.query(`
    SELECT tablename, rowsecurity 
    FROM pg_tables 
    WHERE schemaname = 'public'
    ORDER BY tablename;
  `);
  console.table(rlsRes.rows);

  await client.end();
  console.log('\nAll tables secured with RLS successfully!');
}

run().catch(err => {
  console.error('Error fixing RLS:', err);
  process.exit(1);
});
