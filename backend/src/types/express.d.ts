export {};
import { JwtPayload } from "jsonwebtoken";

declare global {
  namespace Express {
    interface Request {
      user?: string | JwtPayload;
      prueba: string
    }
  }
}

