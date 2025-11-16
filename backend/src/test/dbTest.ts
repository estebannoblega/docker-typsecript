import dotenv from 'dotenv';
dotenv.config({ path: __dirname + '/../../.env' });


import { pool } from '../config/db';

async function testDB() {
  const [rows] = await pool.query('SELECT 1 + 1 AS result');
  console.log(rows);
  process.exit();
}

testDB();
