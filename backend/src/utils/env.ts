import dotenv from "dotenv";
dotenv.config();

// Validamos que existan las env vars obligatorias
function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`La variable de entorno ${name} es obligatoria`);
  }
  return value;
}

export const env = {
  DB_HOST_API: required("DB_HOST_API"),
  DB_USER_API: required("DB_USER_API"),
  DB_PASS_API: required("DB_PASS_API"),
  DB_NAME_API: required("DB_NAME_API"),
  DB_PORT_API: Number(required("DB_PORT_API")), // aqui definimos que sea un número
};
