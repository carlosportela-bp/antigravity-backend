const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASS
});

async function run() {
  try {
    const res = await pool.query(`
      SELECT column_name, data_type, udt_name 
      FROM information_schema.columns 
      WHERE table_name = 'clientes' 
      ORDER BY ordinal_position
    `);
    console.log('CLIENTES SCHEMA:', res.rows);
    
    const enums = await pool.query(`
      SELECT t.typname as enum_name, e.enumlabel as value
      FROM pg_type t 
      JOIN pg_enum e ON t.oid = e.enumtypid
      ORDER BY t.typname, e.enumsortorder
    `);
    console.log('ENUMS:', enums.rows);
    
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
run();
