import { pool } from './db.js';
import fs from 'fs';
import dotenv from 'dotenv';
dotenv.config();

async function run() {
  try {
    const res = await pool.query(`
      SELECT column_name, data_type, udt_name, ordinal_position
      FROM information_schema.columns 
      WHERE table_name = 'clientes' 
      ORDER BY ordinal_position
    `);
    fs.writeFileSync('schema_output.json', JSON.stringify(res.rows, null, 2));
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}
run();
