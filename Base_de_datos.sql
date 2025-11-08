-- =======================================================
-- CREACIÓN DE BASE DE DATOS
-- =======================================================

CREATE DATABASE IF NOT EXISTS gestion_eventos;
USE gestion_eventos;

-----------------------------------------------------
-- TABLA: Facultad
-----------------------------------------------------
CREATE TABLE facultad (
    id_facultad BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

-----------------------------------------------------
-- TABLA: Unidad Académica
-----------------------------------------------------
CREATE TABLE unidad_academica (
    id_unidad_academica BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    id_facultad BIGINT UNSIGNED NOT NULL,
    FOREIGN KEY (id_facultad) REFERENCES facultad(id_facultad)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Usuario
-----------------------------------------------------
CREATE TABLE usuario (
    id_usuario BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL,
    apellido VARCHAR(60) NOT NULL,
    correo VARCHAR(120) NOT NULL UNIQUE,
    rol ENUM('Docente','Estudiante','Secretario','Administrador') NOT NULL,
    estado ENUM('Activo','Inactivo') NOT NULL DEFAULT 'Activo'
);

-----------------------------------------------------
-- TABLA: Tipo de Evento
-----------------------------------------------------
CREATE TABLE tipo_evento (
    id_tipo BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(60) NOT NULL UNIQUE
);

-----------------------------------------------------
-- TABLA: Evento
-----------------------------------------------------
CREATE TABLE evento (
    id_evento BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(60) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    id_usuario BIGINT UNSIGNED NOT NULL,
    id_unidad_academica BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_unidad_academica) REFERENCES unidad_academica(id_unidad_academica)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Evaluacion
-----------------------------------------------------
CREATE TABLE evaluacion (
    id_evaluacion BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_evento BIGINT UNSIGNED NOT NULL,
    estado ENUM('Pendiente','Aprobado','Rechazado') NOT NULL,
    justificacion TEXT,

    FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Organizacion
-----------------------------------------------------
CREATE TABLE organizacion (
    id_organizacion BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(120) NOT NULL UNIQUE,
    representante_legal VARCHAR(120) NOT NULL,
    telefono VARCHAR(30),
    ubicacion VARCHAR(120)
);

-----------------------------------------------------
-- TABLA: Participacion
-----------------------------------------------------
CREATE TABLE participacion (
    id_participacion BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_evento BIGINT UNSIGNED NOT NULL,
    id_organizacion BIGINT UNSIGNED NOT NULL,
    participante VARCHAR(120) NOT NULL,
    es_representante_legal BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_organizacion) REFERENCES organizacion(id_organizacion)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Historial de Contraseñas
-----------------------------------------------------
CREATE TABLE historial_contrasenas (
    id_historial BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_usuario BIGINT UNSIGNED NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    vigente BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Notificacion
-----------------------------------------------------
CREATE TABLE notificacion (
    id_notificacion BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_usuario BIGINT UNSIGNED NOT NULL,
    mensaje VARCHAR(255) NOT NULL,
    leida BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Horario (NUEVA)
-----------------------------------------------------
CREATE TABLE horario (
    id_horario BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_evento BIGINT UNSIGNED NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,

    FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Reserva (NUEVA)
-----------------------------------------------------
CREATE TABLE reserva (
    id_reserva BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_usuario BIGINT UNSIGNED NOT NULL,
    id_evento BIGINT UNSIGNED NOT NULL,
    fecha_reserva DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Activa','Cancelada') NOT NULL DEFAULT 'Activa',

    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- TABLA: Historial (NUEVA)
-----------------------------------------------------
CREATE TABLE historial (
    id_historial BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    id_reserva BIGINT UNSIGNED NOT NULL,
    accion VARCHAR(150) NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_responsable BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (usuario_responsable) REFERENCES usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-----------------------------------------------------
-- INSERTS
-----------------------------------------------------

INSERT INTO facultad (nombre) VALUES
('Facultad de Ingeniería'),
('Facultad de Humanidades'),
('Facultad de Ciencias Económicas'),
('Facultad de Arquitectura y Diseño'),
('Facultad de Comunicación'),
('Facultad de Ciencias de la Salud'),
('Facultad de Derecho');

INSERT INTO unidad_academica (nombre, id_facultad) VALUES
('Ciencias de la Computación', 1),
('Ingeniería Industrial', 1),
('Comunicación Social', 5),
('Administración de Empresas', 3),
('Diseño Gráfico', 4),
('Psicología', 6),
('Derecho Público', 7);

INSERT INTO usuario (nombre, apellido, correo, rol, estado) VALUES
('Lorena', 'Martínez', 'lorena.martinez@uao.edu.co', 'Estudiante', 'Activo'),
('Samuel', 'Murillo', 'samuel.murillo@uao.edu.co', 'Docente', 'Activo'),
('Sofía', 'Hernández', 'sofia.hernandez@uao.edu.co', 'Administrador', 'Activo'),
('David', 'Rojas', 'david.rojas@uao.edu.co', 'Estudiante', 'Inactivo'),
('Vanesa', 'Cruz', 'vanesa.cruz@uao.edu.co', 'Docente', 'Activo'),
('Carlos', 'Mejía', 'carlos.mejia@uao.edu.co', 'Docente', 'Activo'),
('Laura', 'Gómez', 'laura.gomez@uao.edu.co', 'Estudiante', 'Activo');

INSERT INTO evento (nombre, tipo, fecha_inicio, fecha_fin, id_usuario, id_unidad_academica) VALUES
('Seminario Big Data', 'Académico', '2025-10-05', '2025-10-06', 1, 1),
('Foro de Innovación', 'Académico', '2025-09-20', '2025-09-22', 2, 1),
('Festival de Teatro', 'Cultural', '2025-08-10', '2025-08-12', 3, 3),
('Torneo de Voleibol', 'Deportivo', '2025-07-15', '2025-07-17', 4, 2),
('Simposio de Psicología', 'Académico', '2025-05-10', '2025-05-12', 5, 6),
('Jornada de Derecho Público', 'Social', '2025-04-03', '2025-04-04', 6, 7),
('Concurso de Diseño', 'Cultural', '2025-03-15', '2025-03-18', 7, 5);

INSERT INTO evaluacion (id_evento, estado, justificacion) VALUES
(1, 'Aprobado', 'Cumple todos los requisitos académicos.'),
(2, 'Pendiente', 'Falta documentación.'),
(3, 'Rechazado', 'No cumple con criterios culturales.'),
(4, 'Aprobado', 'Evento bien organizado.'),
(5, 'Aprobado', 'Se ajusta al plan institucional.'),
(6, 'Pendiente', 'Falta revisión de seguridad.'),
(7, 'Rechazado', 'Inconsistencias en los registros.');

INSERT INTO organizacion (nombre, representante_legal, telefono, ubicacion) VALUES
('DataSolutions Ltda.', 'Sebastián Peña', '3129001111', 'Cali, Valle'),
('DeportesUAO', 'María Quiroz', '3129002222', 'Cali, Valle'),
('EcoVerde S.A.S.', 'Gabriela Muñoz', '3193244558', 'Palmira, Valle'),
('SaludGlobal IPS', 'Camilo Ordoñez', '3129004444', 'Cali, Valle'),
('Cultura Activa', 'Lucía Ramírez', '3178001112', 'Jamundí, Valle'),
('Legem Consulting', 'Daniel Torres', '3101234567', 'Cali, Valle'),
('PsicoVidas', 'Alejandra López', '3129988776', 'Palmira, Valle');

INSERT INTO participacion (id_evento, id_organizacion, participante, es_representante_legal) VALUES
(1, 1, 'Gabriel Peña', TRUE),
(1, 1, 'Sofía Reyes', FALSE),
(2, 2, 'Laura Quintero', TRUE),
(3, 5, 'Daniel Ruiz', FALSE),
(4, 2, 'Carlos Meneses', TRUE),
(5, 7, 'Valeria Pérez', FALSE),
(6, 6, 'Diego Lozano', TRUE);

INSERT INTO historial_contrasenas (id_usuario, contrasena, vigente) VALUES
(1, '$2y$10$hash1', TRUE),
(2, '$2y$10$hash2', TRUE),
(3, '$2y$10$hash3', TRUE),
(4, '$2y$10$hash4', FALSE),
(5, '$2y$10$hash5', TRUE),
(6, '$2y$10$hash6', TRUE),
(7, '$2y$10$hash7', TRUE);

INSERT INTO notificacion (id_usuario, mensaje, leida) VALUES
(1, 'Su evento "Seminario Big Data" fue aprobado.', FALSE),
(2, 'Su evento "Foro de Innovación" está pendiente.', FALSE),
(3, 'Su evento "Festival de Teatro" fue rechazado.', TRUE),
(4, 'Su evento "Torneo de Voleibol" fue aprobado.', TRUE),
(5, 'Su evento "Simposio de Psicología" fue aprobado.', FALSE),
(6, 'Su evento "Jornada de Derecho Público" está pendiente.', FALSE),
(7, 'Su evento "Concurso de Diseño" fue rechazado.', FALSE);

-----------------------------------------------------
-- INSERTS: Horarios 
-----------------------------------------------------
INSERT INTO horario (id_evento, hora_inicio, hora_fin) VALUES
(1, '08:00:00', '10:00:00'),
(1, '10:30:00', '12:00:00'),
(2, '09:00:00', '11:00:00'),
(3, '14:00:00', '16:00:00');

-----------------------------------------------------
-- INSERTS: Reservas 
-----------------------------------------------------
INSERT INTO reserva (id_usuario, id_evento, estado) VALUES
(1, 1, 'Activa'),
(2, 1, 'Activa'),
(3, 2, 'Activa'),
(4, 3, 'Cancelada'),
(5, 4, 'Activa'),
(6, 5, 'Activa'),
(7, 6, 'Cancelada');

-----------------------------------------------------
-- INSERTS: Historial (prueba)
-----------------------------------------------------
INSERT INTO historial (id_reserva, accion, usuario_responsable) VALUES
(1, 'Reserva creada', 1),
(1, 'Reserva modificada', 3),
(2, 'Reserva cancelada', 2),
(3, 'Reserva creada', 3),
(4, 'Reserva cancelada', 4),
(5, 'Reserva creada', 5);

-- =======================================================
-- FUNCIONES
-- =======================================================

DELIMITER //
CREATE FUNCTION fn_duracion_evento_dias(p_id_evento BIGINT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE dias INT;
    SELECT DATEDIFF(fecha_fin, fecha_inicio)
    INTO dias
    FROM evento
    WHERE id_evento = p_id_evento;
    RETURN dias;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_eventos_aprobados_por_unidad(p_id_unidad BIGINT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*)
    INTO total
    FROM evento e
    JOIN evaluacion ev ON ev.id_evento = e.id_evento
    WHERE e.id_unidad_academica = p_id_unidad
      AND ev.estado = 'Aprobado';
    RETURN total;
END //
DELIMITER ;

-- =======================================================
-- VISTAS
-- =======================================================

CREATE VIEW vw_eventos_resumen AS
SELECT 
    e.id_evento,
    e.nombre AS evento,
    e.tipo,
    e.fecha_inicio,
    e.fecha_fin,
    CONCAT(u.nombre, ' ', u.apellido) AS organizador,
    ua.nombre AS unidad_academica
FROM evento e
LEFT JOIN usuario u ON e.id_usuario = u.id_usuario
LEFT JOIN unidad_academica ua ON e.id_unidad_academica = ua.id_unidad_academica;

CREATE VIEW vw_eventos_organizaciones AS
SELECT 
    e.id_evento,
    e.nombre AS evento,
    o.id_organizacion,
    o.nombre AS organizacion,
    o.representante_legal,
    p.participante
FROM evento e
JOIN participacion p ON e.id_evento = p.id_evento
JOIN organizacion o ON o.id_organizacion = p.id_organizacion;

CREATE VIEW vw_responsables_por_evento AS
SELECT 
    e.id_evento,
    e.nombre AS evento,
    u.id_usuario,
    CONCAT(u.nombre, ' ', u.apellido) AS responsable
FROM evento e
JOIN usuario u ON e.id_usuario = u.id_usuario;

-- =======================================================
-- TRIGGERS
-- =======================================================

DELIMITER //
CREATE TRIGGER tr_evaluacion_after_insert
AFTER INSERT ON evaluacion
FOR EACH ROW
BEGIN
    INSERT INTO notificacion(id_usuario, mensaje, leida)
    SELECT e.id_usuario,
           CONCAT('Su evento "', e.nombre, '" fue ', NEW.estado,
                  '. Justificación: ', IFNULL(NEW.justificacion, 'Sin justificación')),
           FALSE
    FROM evento e
    WHERE e.id_evento = NEW.id_evento;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_historial_contrasenas_before_insert
BEFORE INSERT ON historial_contrasenas
FOR EACH ROW
BEGIN
    IF NEW.vigente = TRUE THEN
        UPDATE historial_contrasenas
        SET vigente = FALSE
        WHERE id_usuario = NEW.id_usuario;
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_evento_before_insert
BEFORE INSERT ON evento
FOR EACH ROW
BEGIN
    IF NEW.fecha_fin < NEW.fecha_inicio THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'fecha_fin no puede ser menor que fecha_inicio';
    END IF;
END //
DELIMITER ;

-- =======================================================
-- FIN DEL SCRIPT
-- =======================================================