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

/* ============================================================
   REGISTRO DE USUARIO
   Campos esperados: email, password
   Tabla: usuarios (email, password)
============================================================ */

export const registerUser = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ message: 'Email y contraseña son obligatorios' });
    return;
  }

  try {
    // ¿El usuario ya existe?
    const [existingUser] = await pool.query<UserRow[]>(
      'SELECT idUsuario FROM usuarios WHERE email = ? LIMIT 1',
      [email]
    );

    if (Array.isArray(existingUser) && existingUser.length > 0) {
      res.status(409).json({ message: 'El email ya está registrado' });
      return;
    }

    // Hashear contraseña
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insertar usuario
    await pool.query(
      'INSERT INTO usuarios (email, password) VALUES (?, ?)',
      [email, hashedPassword]
    );

    res.status(201).json({ message: 'Usuario registrado con éxito' });

  } catch (error) {
    console.error('Error en registerUser:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};


/* ============================================================
   LOGIN DE USUARIO
   Campos esperados: email, password
============================================================ */

export const loginUser = async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ message: 'Email y contraseña son obligatorios' });
    return;
  }

  try {
    // Buscar usuario
    const [rows] = await pool.query<UserRow[]>(
      'SELECT idUsuario, password FROM usuarios WHERE email = ? LIMIT 1',
      [email]
    );

    const data = Array.isArray(rows) ? rows[0] : undefined;

    if (!data) {
      res.status(401).json({ message: 'Credenciales inválidas' });
      return;
    }

    // Comparar contraseña
    const passwordIsValid = await bcrypt.compare(password, data.password);
    if (!passwordIsValid) {
      res.status(401).json({ message: 'Credenciales inválidas' });
      return;
    }

    // Crear token
    const token = jwt.sign(
      { idUsuario: data.idUsuario, email },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({ token });

  } catch (error) {
    console.error('Error en loginUser:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};
