//creo este archivo porque agregar la propiedad user de forma global no funciona
import type { Request } from "express";
import type { JwtPayload } from "jsonwebtoken";

export interface AuthenticatedRequest extends Request {
    user?: JwtPayload | string
}
