import { pool } from '../config/db';
import { hashPassword } from '../utils/hash';

async function seedUsers() {
  try {
    console.log('🌱 Iniciando seeder de usuarios...');

    const users = [
      { email: 'admin@example.com', password: 'admin123' },
      { email: 'user@example.com', password: 'usuario123' },
      { email: 'test@example.com', password: 'test123' },
    ];

    for (const user of users) {
      const hashed = await hashPassword(user.password);

      await pool.query(
        `INSERT INTO usuarios (email, password) VALUES (?, ?)`,
        [user.email, hashed]
      );

      console.log(`✔ Usuario insertado: ${user.email}`);
    }

    console.log('🌱 Seeder completado con éxito.');
  } catch (error) {
    console.error('❌ Error en el seeder:', error);
  } finally {
    pool.end();
  }
}

seedUsers();
