import dotenv from 'dotenv';

dotenv.config({ path: '/app/.env' });

console.log("ENV COMPLETO:", {
  PORT: process.env.PORT_API,
  JWT_SECRET: process.env.JWT_SECRET_API,
  DB_USER: process.env.DB_USER_API,
  DB_PASS: process.env.DB_PASS_API,
  DB_HOST: process.env.DB_HOST_API,
  DB_NAME: process.env.DB_NAME_API,
  DB_PORT: process.env.DB_PORT_API,
});
