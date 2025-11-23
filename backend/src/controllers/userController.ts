// src/controllers/userController.ts
import type { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { pool } from '../config/db';
import dotenv from 'dotenv';
import { UserRow } from '../types/db';

dotenv.config({ path: '/app/.env' });

// Validamos la secret
const JWT_SECRET = process.env.JWT_SECRET_API;
if (!JWT_SECRET) {
  throw new Error('Falta JWT_SECRET_API en el archivo .env');
}
/**
 * Registra un nuevo usuario en la base de datos.
 *
 * @function registerUser
 * @async
 * @param {Request} req - Objeto Request de Express. Debe contener en req.body los campos:
 * @param {string} req.body.email - Email del usuario a registrar.
 * @param {string} req.body.password - Contraseña del usuario.
 *
 * @param {Response} res - Objeto Response de Express usado para enviar la respuesta al cliente.
 *
 * @returns {Promise<void>} No retorna nada directamente. Responde al cliente con:
 * - 201 si el usuario fue registrado con éxito.
 * - 400 si faltan campos.
 * - 409 si el email ya existe.
 * - 500 si ocurre un error interno.
 *
 * @description
 * Esta función:
 * 1. Valida que email y contraseña estén presentes.
 * 2. Verifica si el usuario ya existe.
 * 3. Hashea la contraseña con bcrypt.
 * 4. Inserta el usuario en la tabla `usuarios`.
 * 5. Devuelve un mensaje JSON según el resultado.
 */
export const registerUser = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ message: 'Email y contraseña son obligatorios' });
    return;
  }

  try {
    // Hashear contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Ejecutar el SP
    await pool.query(
      'CALL sp_registrar_usuario(?, ?)',
      [email, hashedPassword]
    );

    res.status(201).json({ message: 'Usuario registrado con éxito' });

  } catch (error: any) {

    // Mensaje que envía tu SP
    if (error.message.includes('El correo ya está registrado')) {
      res.status(409).json({ message: 'El email ya está registrado' });
      return;
    }

    console.error('Error en registerUser:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};


/**
 * Inicia sesión para un usuario existente.
 *
 * @function loginUser
 * @async
 * @param {Request} req - Objeto Request de Express. Debe contener en req.body:
 * @param {string} req.body.email - Email del usuario.
 * @param {string} req.body.password - Contraseña del usuario.
 *
 * @param {Response} res - Objeto Response de Express usado para enviar la respuesta al cliente.
 *
 * @returns {Promise<void>} No retorna nada directamente. Envía:
 * - 200 con el token JWT si las credenciales son correctas.
 * - 400 si faltan campos.
 * - 401 si las credenciales son inválidas.
 * - 500 si ocurre un error interno.
 *
 * @description
 * Esta función:
 * 1. Valida email y contraseña.
 * 2. Busca el usuario por email.
 * 3. Compara la contraseña usando bcrypt.
 * 4. Genera un token JWT con expiración de 1 hora.
 * 5. Devuelve el token en un JSON.
 */
export const loginUser = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ message: 'Email y contraseña son obligatorios' });
    return;
  }

  try {
    // Llamar al stored procedure
    const [rows] = await pool.query<any[]>(
      'CALL sp_buscar_usuario_por_email(?)',
      [email]
    );

    /**
     * IMPORTANTE:
     * Cuando CALL se usa en MySQL/MariaDB, el resultado llega como:
     * [
     *   [ { idUsuario, email, password }, ... ],  <-- primer recordset
     *   { ... metadata ... }
     * ]
     *
     * Por eso rows[0][0] es el usuario real.
     */
    const user = rows[0][0];

    if (!user) {
      res.status(401).json({ message: 'Credenciales inválidas' });
      return;
    }

    // Comparar contraseña
    const passwordIsValid = await bcrypt.compare(password, user.password);
    if (!passwordIsValid) {
      res.status(401).json({ message: 'Credenciales inválidas' });
      return;
    }

    // Crear token
    const token = jwt.sign(
      { idUsuario: user.idUsuario, email: user.email },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({ token });

  } catch (error) {
    console.error('Error en loginUser:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

