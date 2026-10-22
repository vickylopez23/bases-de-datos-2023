-- Parcial 1 de Bases de Datos (base olympics)
-- Para ubicarse: una persona (person) participa en unos juegos como competidor (games_competitor),
-- y cada competidor compite en eventos (competitor_event), donde queda registrada la medalla (medal).
-- En medal hay una fila 'NA' para los que no ganaron nada, así que en todos lados la descarto.
USE olympics;

-- 1. Crear un campo nuevo `total_medals` en la tabla `person` que almacena la cantidad de medallas ganadas por cada persona.
--    Por defecto, con valor 0.
ALTER TABLE person ADD COLUMN total_medals INT DEFAULT 0;

-- 2. Actualizar la columna `total_medals` de cada persona con el recuento real de medallas que ganó.
--    Por ejemplo, para Michael Fred Phelps II, luego de la actualización debería tener como valor de `total_medals` igual a 28.
-- Para cada persona cuento sus filas en competitor_event que tienen una medalla de verdad (no 'NA').
UPDATE person p
SET total_medals = (
    SELECT COUNT(*)
    FROM games_competitor gc
    JOIN competitor_event ce ON ce.competitor_id = gc.id
    JOIN medal m ON m.id = ce.medal_id
    WHERE gc.person_id = p.id AND m.medal_name <> 'NA'
);

-- Para chequear que Phelps quedó con 28:
-- SELECT full_name, total_medals FROM person WHERE full_name LIKE 'Michael Fred Phelps%';

-- 3. Devolver todos los medallistas olímpicos de Argentina, es decir, los que hayan logrado alguna medalla de oro, plata, o bronce,
--    enumerando la cantidad por tipo de medalla. Por ejemplo, la query debería retornar casos como el siguiente:
--    (Juan Martín del Potro, Bronze, 1), (Juan Martín del Potro, Silver, 1)
-- Junto la persona con su país (person_region -> noc_region) y con sus medallas, y cuento por persona y tipo de medalla.
SELECT p.full_name, m.medal_name, COUNT(*) AS medals
FROM person p
JOIN person_region pr ON pr.person_id = p.id
JOIN noc_region r ON r.id = pr.region_id
JOIN games_competitor gc ON gc.person_id = p.id
JOIN competitor_event ce ON ce.competitor_id = gc.id
JOIN medal m ON m.id = ce.medal_id
WHERE r.region_name = 'Argentina' AND m.medal_name <> 'NA'
GROUP BY p.id, p.full_name, m.medal_name;

-- 4. Listar el total de medallas ganadas por los deportistas argentinos en cada deporte.
-- Igual que la anterior pero llego hasta el deporte (competitor_event -> event -> sport) y agrupo solo por deporte.
SELECT s.sport_name, COUNT(*) AS medals
FROM person p
JOIN person_region pr ON pr.person_id = p.id
JOIN noc_region r ON r.id = pr.region_id
JOIN games_competitor gc ON gc.person_id = p.id
JOIN competitor_event ce ON ce.competitor_id = gc.id
JOIN medal m ON m.id = ce.medal_id
JOIN event e ON e.id = ce.event_id
JOIN sport s ON s.id = e.sport_id
WHERE r.region_name = 'Argentina' AND m.medal_name <> 'NA'
GROUP BY s.sport_name
ORDER BY medals DESC;

-- 5. Listar el número total de medallas de oro, plata y bronce ganadas por cada país (país representado en la tabla `noc_region`),
--    agruparlas los resultados por pais.
-- Lo guardo en una vista porque lo reutilizo en el ejercicio 6.
CREATE OR REPLACE VIEW medals_for_country AS
SELECT r.region_name AS country, m.medal_name, COUNT(*) AS amount
FROM noc_region r
JOIN person_region pr ON pr.region_id = r.id
JOIN games_competitor gc ON gc.person_id = pr.person_id
JOIN competitor_event ce ON ce.competitor_id = gc.id
JOIN medal m ON m.id = ce.medal_id
WHERE m.medal_name <> 'NA'
GROUP BY r.region_name, m.medal_name;

SELECT * FROM medals_for_country;

-- 6. Listar el país con más y menos medallas ganadas en la historia de las olimpiadas.
-- Sumo los tres tipos de medalla de cada país y junto el primero (más medallas) con el último (menos medallas).
(SELECT country, SUM(amount) AS total FROM medals_for_country GROUP BY country ORDER BY total DESC LIMIT 1)
UNION
(SELECT country, SUM(amount) AS total FROM medals_for_country GROUP BY country ORDER BY total ASC LIMIT 1);

-- 7. Crear dos triggers:
--    Un trigger llamado `increase_number_of_medals` que incrementará en 1 el valor del campo `total_medals` de la tabla `person`.
--    Un trigger llamado `decrease_number_of_medals` que decrementará en 1 el valor del campo `totals_medals` de la tabla `person`.
--    El primer trigger se ejecutará luego de un `INSERT` en la tabla `competitor_event` y deberá actualizar el valor en la tabla
--    `person` de acuerdo al valor introducido (i.e. sólo aumentará en 1 el valor de `total_medals` para la persona que ganó una medalla).
--    Análogamente, el segundo trigger se ejecutará luego de un `DELETE` en la tabla `competitor_event` y sólo actualizará el valor
--    en la persona correspondiente.
-- Cada trigger es un solo UPDATE: busco la persona del competidor y le sumo (o resto) 1, solo si la medalla no es 'NA'.
-- NEW es la fila recién insertada y OLD la fila que se borró.
DROP TRIGGER IF EXISTS increase_number_of_medals;
CREATE TRIGGER increase_number_of_medals
AFTER INSERT ON competitor_event
FOR EACH ROW
    UPDATE person p
    JOIN games_competitor gc ON gc.person_id = p.id
    JOIN medal m ON m.id = NEW.medal_id
    SET p.total_medals = p.total_medals + 1
    WHERE gc.id = NEW.competitor_id AND m.medal_name <> 'NA';

DROP TRIGGER IF EXISTS decrease_number_of_medals;
CREATE TRIGGER decrease_number_of_medals
AFTER DELETE ON competitor_event
FOR EACH ROW
    UPDATE person p
    JOIN games_competitor gc ON gc.person_id = p.id
    JOIN medal m ON m.id = OLD.medal_id
    SET p.total_medals = p.total_medals - 1
    WHERE gc.id = OLD.competitor_id AND m.medal_name <> 'NA';

-- Para probarlos (el competidor 125108 es de Phelps, que tiene id de persona 94406):
-- INSERT INTO competitor_event VALUES (1, 125108, 1);
-- SELECT total_medals FROM person WHERE id = 94406;   -- 29
-- DELETE FROM competitor_event WHERE competitor_id = 125108 AND event_id = 1 LIMIT 1;
-- SELECT total_medals FROM person WHERE id = 94406;   -- vuelve a 28

-- 8. Crear un procedimiento `add_new_medalists` que tomará un `event_id`, y tres ids de atletas `g_id`, `s_id`, y `b_id` donde se
--    deberá insertar tres registros en la tabla `competitor_event` asignando a `g_id` la medalla de oro, a `s_id` la medalla de plata,
--    y a `b_id` la medalla de bronce.
-- Un solo INSERT con las tres filas; el id de cada medalla lo busco por su nombre.
DROP PROCEDURE IF EXISTS add_new_medalists;
CREATE PROCEDURE add_new_medalists(IN p_event INT, IN g_id INT, IN s_id INT, IN b_id INT)
    INSERT INTO competitor_event (event_id, competitor_id, medal_id) VALUES
        (p_event, g_id, (SELECT id FROM medal WHERE medal_name = 'Gold')),
        (p_event, s_id, (SELECT id FROM medal WHERE medal_name = 'Silver')),
        (p_event, b_id, (SELECT id FROM medal WHERE medal_name = 'Bronze'));

-- 9. Crear el rol `organizer` y asignarle permisos de eliminación sobre la tabla `games` y permiso de actualización sobre la columna
--    `games_name` de la tabla `games`.
-- El permiso de UPDATE va con la columna entre paréntesis para que solo pueda tocar esa.
DROP ROLE IF EXISTS organizer;
CREATE ROLE organizer;
GRANT DELETE ON olympics.games TO organizer;
GRANT UPDATE (games_name) ON olympics.games TO organizer;
