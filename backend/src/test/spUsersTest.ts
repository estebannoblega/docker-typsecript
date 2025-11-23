import {pool} from '../config/db';

import mysql from 'mysql2/promise';

async function main() {
  

  try {
    console.log("=== TEST: Registrar usuario ===");
    await pool.query(`CALL sp_registrar_usuario(?, ?)`, [
      "prueba1@test.com",
      "12345",
    ]);
    console.log("Usuario registrado");

  } catch (error: any) {
    console.error("Error registrando usuario:", error.message);
  }

  try {
    console.log("\n=== TEST: Buscar usuario ===");
    const [rows]: any = await pool.query(
      `CALL sp_buscar_usuario_por_email(?)`,
      ["prueba1@test.com"]
    );

    const usuario = rows[0][0];
    console.log("Resultado:", usuario);

  } catch (error: any) {
    console.error("Error buscando usuario:", error.message);
  }

  try {
    console.log("\n=== TEST: Cambiar password ===");
    await pool.query(
      `CALL sp_modificar_password_por_email(?, ?)`,
      ["prueba1@test.com", "nuevaClave123"]
    );
    console.log("Password cambiada");

  } catch (error: any) {
    console.error("Error cambiando password:", error.message);
  }

  try {
    console.log("\n=== TEST: Soft delete ===");
    await pool.query(
      `CALL sp_eliminar_usuario(?)`,
      ["prueba1@test.com"]
    );
    console.log("Usuario marcado como inactivo");

  } catch (error: any) {
    console.error("Error en soft delete:", error.message);
  }

  try {
    console.log("\n=== TEST: Restaurar usuario ===");
    await pool.query(
      `CALL sp_restaurar_usuario(?)`,
      ["prueba1@test.com"]
    );
    console.log("Usuario restaurado");

  } catch (error: any) {
    console.error("Error restaurando:", error.message);
  }

  await pool.end();
}

main();
