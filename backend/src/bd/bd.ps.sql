-- PARA CREAR UN NUEVO USUARIO
CREATE USER 'miusuario'@'%' IDENTIFIED BY 'mipassword';




DELIMITER $$

CREATE PROCEDURE sp_registrar_usuario (
    IN p_email VARCHAR(30),
    IN p_password VARCHAR(100)
)
BEGIN
    -- Validar email duplicado
    IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El correo ya está registrado';
    END IF;

    INSERT INTO usuarios (email, password)
    VALUES (p_email, p_password);
END$$

DELIMITER ;

-- BUSCAR UN USUARIO POR EMAIL

DELIMITER $$

CREATE PROCEDURE sp_buscar_usuario_por_email (
    IN p_email VARCHAR(30)
)
BEGIN
    SELECT idUsuario, email, password
    FROM usuarios
    WHERE email = p_email;
END$$

DELIMITER ;

-- MODIFICAR CONTRASEÑA DE USUARIO USANDO ID
DELIMITER $$

CREATE PROCEDURE sp_modificar_password (
    IN p_idUsuario INT UNSIGNED,
    IN p_nuevaPassword VARCHAR(100)
)
BEGIN
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE idUsuario = p_idUsuario) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no existe';
    END IF;

    UPDATE usuarios
    SET password = p_nuevaPassword
    WHERE idUsuario = p_idUsuario;
END$$

DELIMITER ;


-- MODIFICAR CONTRASEÑA DE USUARIO USANDO CORREO
DELIMITER $$

CREATE PROCEDURE sp_modificar_password_por_email (
    IN p_email VARCHAR(30),
    IN p_nuevaPassword VARCHAR(100)
)
BEGIN
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE email = p_email AND activo = 1) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no existe o está inactivo';
    END IF;

    UPDATE usuarios
    SET password = p_nuevaPassword
    WHERE email = p_email;
END$$

DELIMITER ;


-- AGREGADO DE SOFT DELETE

ALTER TABLE usuarios ADD COLUMN activo TINYINT(1) NOT NULL DEFAULT 1;

-- DAR DE BAJA UN USUARIO
DELIMITER $$

CREATE PROCEDURE sp_eliminar_usuario (
    IN p_email VARCHAR(30)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE email = p_email AND activo = 1) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no existe o ya está eliminado';
    END IF;

    UPDATE usuarios
    SET activo = 0
    WHERE email = p_email;
END$$

DELIMITER ;

-- DAR DE ALTA UN USUARIO
DELIMITER $$

CREATE PROCEDURE sp_restaurar_usuario (
    IN p_email VARCHAR(30)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE email = p_email AND activo = 0) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'El usuario no existe o ya está activo';
    END IF;

    UPDATE usuarios
    SET activo = 1
    WHERE email = p_email;
END$$

DELIMITER ;


-- TRIGGER PARA AUDITORIAS
-- CREACION DE TABLA
CREATE TABLE auditoria_usuarios (
    idLog INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT UNSIGNED,
    email VARCHAR(30),
    accion VARCHAR(20),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- TRIGGER PARA REGISTRO DE USUARIOS
DELIMITER $$

CREATE TRIGGER trg_usuarios_insert
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_usuarios (idUsuario, email, accion)
    VALUES (NEW.idUsuario, NEW.email, 'INSERT');
END$$

DELIMITER ;

-- TRIGGER PARA MODIFICACION DE USUARIOS
DELIMITER $$

CREATE TRIGGER trg_usuarios_update
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_usuarios (idUsuario, email, accion)
    VALUES (NEW.idUsuario, NEW.email, 'UPDATE');
END$$

DELIMITER ;

-- TRIGGER PARA DAR BAJA USUARIO
DELIMITER $$

CREATE TRIGGER trg_usuarios_softdelete
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    IF OLD.activo = 1 AND NEW.activo = 0 THEN
        INSERT INTO auditoria_usuarios (idUsuario, email, accion)
        VALUES (NEW.idUsuario, NEW.email, 'DELETE');
    END IF;
END$$

DELIMITER ;


-- TRIGGER PARA ALTA DE USUARIO
DELIMITER $$

CREATE TRIGGER trg_usuarios_restore
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    IF OLD.activo = 0 AND NEW.activo = 1 THEN
        INSERT INTO auditoria_usuarios (idUsuario, email, accion)
        VALUES (NEW.idUsuario, NEW.email, 'RESTORE');
    END IF;
END$$

DELIMITER ;
