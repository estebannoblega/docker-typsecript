import mysql from 'mysql2/promise';
import { env } from '../utils/env';



if(!process.env.DB_HOST_API || !process.env.DB_NAME_API || !process.env.DB_USER_API || !process.env.DB_PASS_API || !process.env.DB_PORT_API){
  throw new Error('Una o más variables de entorno sin definir para la base de datos');
}

export const pool = mysql.createPool({
  host: env.DB_HOST_API,
  user: env.DB_USER_API,
  password: env.DB_PASS_API,
  database: env.DB_NAME_API,
  port: env.DB_PORT_API,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
