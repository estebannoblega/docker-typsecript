import mysql from 'mysql2/promise';
import dotenv from 'dotenv';


export const pool = mysql.createPool({
  host: 'db',
  user: 'web',
  password: 'web.321',
  database: 'apiWeb',
  port: 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
