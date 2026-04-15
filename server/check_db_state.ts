import { pool } from './db.js';
import dotenv from 'dotenv';
dotenv.config();

async function run() {
  try {
    console.log('--- CHECKING CLIENTES TABLE ---');
    const res = await pool.query(`
      SELECT column_name, data_type, udt_name, ordinal_position
      FROM information_schema.columns 
      WHERE table_name = 'clientes' 
      ORDER BY ordinal_position
    `);
    console.table(res.rows);
    
    console.log('\n--- CHECKING STATUS_CASO ENUM ---');
    const enums = await pool.query(`
      SELECT e.enumlabel
      FROM pg_enum e
      JOIN pg_type t ON e.enumtypid = t.oid
      WHERE t.typname = 'status_caso'
    `);
    console.log('Enum values:', enums.rows.map(r => r.enumlabel));
    
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
run();
