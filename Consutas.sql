-- 1. Eventos con su creador, unidad académica y horarios

SELECT e.id_evento, e.nombre AS evento, e.tipo,
       e.fecha_inicio, e.fecha_fin,
       CONCAT(u.nombre, ' ', u.apellido) AS creador,
       ua.nombre AS unidad_academica,
       h.hora_inicio, h.hora_fin
FROM evento e
JOIN usuario u ON e.id_usuario = u.id_usuario
JOIN unidad_academica ua ON e.id_unidad_academica = ua.id_unidad_academica
LEFT JOIN horario h ON e.id_evento = h.id_evento
ORDER BY e.id_evento, h.hora_inicio;

-- 2. Unidades académicas que colaboraron juntas en más de un evento

SELECT 
    ua1.nombre AS unidad_1,
    ua2.nombre AS unidad_2,
    COUNT(*) AS coincidencias
FROM evento e1
JOIN evento e2 ON e1.id_evento < e2.id_evento
JOIN unidad_academica ua1 ON ua1.id_unidad_academica = e1.id_unidad_academica
JOIN unidad_academica ua2 ON ua2.id_unidad_academica = e2.id_unidad_academica
GROUP BY ua1.id_unidad_academica, ua2.id_unidad_academica
HAVING COUNT(*) > 1;

-- 3. Reservas con usuario y evento

SELECT DISTINCT
       r.id_reserva,
       CONCAT(u.nombre, ' ', u.apellido) AS usuario,
       e.nombre AS evento,
       r.fecha_reserva,
       r.estado
FROM reserva r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN evento e ON r.id_evento = e.id_evento
ORDER BY r.id_reserva;


-- 4. Historial de cambios con responsable y reserva

SELECT h.id_historial,
       h.id_reserva,
       h.accion,
       h.fecha_cambio,
       CONCAT(u.nombre, ' ', u.apellido) AS responsable
FROM historial h
JOIN usuario u ON h.usuario_responsable = u.id_usuario
ORDER BY h.fecha_cambio DESC;

-- 5. Cantidad de reservas por usuario
SELECT CONCAT(u.nombre, ' ', u.apellido) AS usuario,
       COUNT(r.id_reserva) AS total_reservas
FROM usuario u
LEFT JOIN reserva r ON u.id_usuario = r.id_usuario
GROUP BY u.id_usuario
ORDER BY total_reservas DESC;

-- 6. Reservas con historial y detalle del usuario responsable de la última modificación

WITH ultimos AS (
    SELECT 
        h.id_reserva,
        h.accion,
        h.usuario_responsable,
        ROW_NUMBER() OVER (PARTITION BY h.id_reserva ORDER BY h.fecha_cambio DESC) AS rn
    FROM historial h
)
SELECT 
    r.id_reserva,
    CONCAT(u.nombre, ' ', u.apellido) AS usuario_duenio_reserva,
    e.nombre AS evento,
    ult.accion AS ultima_accion,
    CONCAT(ur.nombre, ' ', ur.apellido) AS responsable_ultima_accion
FROM reserva r
JOIN usuario u ON r.id_usuario = u.id_usuario
JOIN evento e ON r.id_evento = e.id_evento
JOIN ultimos ult ON r.id_reserva = ult.id_reserva AND ult.rn = 1
JOIN usuario ur ON ult.usuario_responsable = ur.id_usuario;

-- 7. Eventos con su porcentaje de reservas activas vs totales

SELECT 
    e.nombre AS evento,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.estado = 'Activa') AS reservas_activas,
    ROUND(
        (SUM(r.estado = 'Activa') / COUNT(r.id_reserva)) * 100, 2
    ) AS porcentaje_activo
FROM evento e
LEFT JOIN reserva r ON e.id_evento = r.id_evento
GROUP BY e.id_evento;
-- 8. Participación estudiantil por facultad

SELECT 
    f.nombre AS facultad,
    COUNT(e.id_evento) AS total_eventos_estudiantiles
FROM evento e
JOIN usuario u ON u.id_usuario = e.id_usuario
JOIN unidad_academica ua ON ua.id_unidad_academica = e.id_unidad_academica
JOIN facultad f ON f.id_facultad = ua.id_facultad
WHERE u.rol = 'Estudiante'
GROUP BY f.id_facultad;

-- 9. Usuarios que hicieron reserva en un evento, pero NO en otros eventos

SELECT DISTINCT
    CONCAT(u.nombre, ' ', u.apellido) AS usuario
FROM usuario u
JOIN reserva r1 ON u.id_usuario = r1.id_usuario
WHERE r1.id_evento = 1
AND u.id_usuario NOT IN (
    SELECT r2.id_usuario
    FROM reserva r2
    WHERE r2.id_evento <> 1
);

-- 10. Ranking de unidades académicas según impacto

SELECT 
    ua.nombre AS unidad,
    (
        (SELECT COUNT(*) 
         FROM evaluacion ev
         JOIN evento e2 ON e2.id_evento = ev.id_evento
         WHERE ev.estado = 'Aprobado' 
           AND e2.id_unidad_academica = ua.id_unidad_academica)
        +
        (SELECT COUNT(*) 
         FROM evento e3
         JOIN participacion p ON p.id_evento = e3.id_evento
         WHERE e3.id_unidad_academica = ua.id_unidad_academica)
    ) AS puntaje_total
FROM unidad_academica ua
ORDER BY puntaje_total DESC;