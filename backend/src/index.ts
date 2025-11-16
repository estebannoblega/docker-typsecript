import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import userRoutes from './routes/userRoutes';
import protectedWelcome from './routes/protectedWelcome';

dotenv.config({ path: '/app/.env' });

const app = express();

// Middleware
app.use(helmet()); //Esto para headers de seguridad
app.use(cors());    //Limitar dominios
app.use(express.json());

// Rutas
app.use('/api/users',userRoutes);
app.use('/api/protected/', protectedWelcome);


//Configuración del puerto
const PORT = process.env.PORT_API || 5000


//Puesta en marcha del server
app.listen(PORT,()=>{
    console.log(`Servidor corriendo en http://localhost:${PORT}`);
});