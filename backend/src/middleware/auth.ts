// src/middleware/auth.ts
/**
 * Aqui debería manejar toda la lógica relacionada a las sesiones, o sea extraer el token validarlo, etc. Es quien se va a encargar de proteger las rutas
 */


import jwt, { JwtPayload } from 'jsonwebtoken';
import type { Request, Response, NextFunction } from 'express';
import dotenv from 'dotenv';

interface RequestConUser extends Request{
  user?: string | JwtPayload;
}

dotenv.config({ path: '/app/.env' });

const secret = process.env.JWT_SECRET_API;
if (!secret) {
  throw new Error('JWT_SECRET_API no está definido en .env');
}

export const verifyToken = (req: RequestConUser, res: Response, next: NextFunction): void => {

  const token = req.headers['authorization']?.split(' ')[1]; // "Bearer token"

  if (!token) {
    res.status(401).json({ message: 'Debe iniciar sesión' });
    return;
  }

  try {
    const decoded = jwt.verify(token, secret);
    // Guardamos los datos del usuario dentro del request
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: 'La sesión ha expirado' });
  }
};
