/**
 * Este archivo es una utilidad, encapsula la lógica del hasing y comparación de contraseñas, es decir, es una lógica necesaria pero no propia del negocio
 */

// src/utils/hash.ts
import bcrypt from 'bcrypt';

export const hashPassword = async (password: string): Promise<string> => {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
};

export const verifyPassword = async (password: string, hash: string): Promise<boolean> => {
  return await bcrypt.compare(password, hash);
};
