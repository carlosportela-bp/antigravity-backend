import { pool } from './db.js';
import dotenv from 'dotenv';
dotenv.config();

async function migrate() {
  try {
    console.log('--- STARTING DATABASE SCHEMA MODERNIZATION ---');
    
    // 1. Convert categoria_servico to TEXT
    console.log('Converting categoria_servico to VARCHAR(100)...');
    await pool.query(`
      ALTER TABLE clientes 
      ALTER COLUMN categoria_servico TYPE VARCHAR(100) 
      USING categoria_servico::text;
    `);

    // 2. Convert status_pagamento to TEXT
    console.log('Converting status_pagamento to VARCHAR(100)...');
    await pool.query(`
      ALTER TABLE clientes 
      ALTER COLUMN status_pagamento TYPE VARCHAR(100) 
      USING status_pagamento::text;
    `);

    // 3. Convert status_caso to TEXT
    console.log('Converting status_caso to VARCHAR(100)...');
    await pool.query(`
      ALTER TABLE clientes 
      ALTER COLUMN status_caso TYPE VARCHAR(100) 
      USING status_caso::text;
    `);

    console.log('✅ DATABASE CONVERTED TO FLEXIBLE TEXT COLUMNS');
    process.exit(0);
  } catch (err) {
    console.error('❌ MIGRATION FAILED:', err);
    process.exit(1);
  }
}
migrate();
