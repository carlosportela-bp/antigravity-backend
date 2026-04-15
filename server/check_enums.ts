import { pool } from './db.js';
import dotenv from 'dotenv';
dotenv.config();

async function run() {
  try {
    console.log('--- ENUM DIAGNOSTIC ---');
    const res = await pool.query(`
      SELECT t.typname as enum_name, e.enumlabel as value
      FROM pg_type t 
      JOIN pg_enum e ON t.oid = e.enumtypid
      ORDER BY t.typname, e.enumsortorder
    `);
    console.table(res.rows);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
run();
