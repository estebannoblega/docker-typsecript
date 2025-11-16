//Ruta de prueba para verificar si funciona el middleware

import { Router } from "express";
import { verifyToken } from "../middleware/auth";
import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from "../types/authenticated-request";


const router = Router();

//Defino las rutas de prueba

router.get('/welcome',verifyToken,(req:AuthenticatedRequest,res:Response)=>{
    res.json({
        message: "Bienvenido",
        userData: req.user
    })
});

export default router; 