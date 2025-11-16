/* La idea de este archivo es que contenga toda la capa lógica de negocio. Su función va a a ser serparar la lógica del controlador (en este caso userController) de la interaccción con la base de datos o la manipulación de datos.
*/

// src/services/userService.ts
import { hashPassword, verifyPassword } from '../utils/hash';

interface User {
  username: string;
  passwordHash: string;
}

// Simulación temporal (en memoria)
const fakeUsers: User[] = [];

export const createUser = async (username: string, password: string): Promise<void> => {
  const passwordHash = await hashPassword(password);
  fakeUsers.push({ username, passwordHash });
};

export const validateUser = async (username: string, password: string): Promise<boolean> => {
  const user = fakeUsers.find(u => u.username === username);
  if (!user) return false;
  return await verifyPassword(password, user.passwordHash);
};
