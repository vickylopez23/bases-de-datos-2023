-- Práctico 5: modificar la base sakila (tablas nuevas, updates, triggers, procedimientos y roles)
-- Ojo: este archivo cambia la base. Las columnas nuevas (premium_customer y stock) se agregan una sola vez;
-- si lo querés correr de nuevo, recargá sakila antes.
USE sakila;

-- 1. Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.
DROP TABLE IF EXISTS directors;
CREATE TABLE directors (
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    movies INT
);

-- 2. El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia (i.e. el mayor número de películas filmadas)
--    son también directores de las películas en las que participaron. Basados en esta información, inserten, utilizando una subquery
--    los valores correspondientes en la tabla `directors`.
-- El SELECT de adentro cuenta las películas de cada actor y se queda con los 5 que más tienen; eso se inserta directo.
INSERT INTO directors
SELECT a.first_name, a.last_name, COUNT(*) AS movies
FROM actor a
JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY movies DESC
LIMIT 5;

-- 3. Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no.
--    Por defecto ningún cliente será premium.
-- Con ENUM la columna solo acepta 'T' o 'F', y arranca en 'F' para todos.
ALTER TABLE customer ADD COLUMN premium_customer ENUM('T', 'F') NOT NULL DEFAULT 'F';

-- 4. Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 clientes con mayor dinero gastado en la plataforma.
-- Saco los 10 que más gastaron en una tabla temporal (top10) y actualizo solo a esos con un JOIN.
UPDATE customer c
JOIN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 10
) top10 ON top10.customer_id = c.customer_id
SET c.premium_customer = 'T';

-- 5. Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings de las películas existentes
--    (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).
SELECT rating, COUNT(*) AS films
FROM film
GROUP BY rating
ORDER BY films DESC;

-- 6. ¿Cuáles fueron la primera y última fecha donde hubo pagos?
SELECT MIN(payment_date) AS first_payment, MAX(payment_date) AS last_payment
FROM payment;

-- 7. Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el nombre del mes de una fecha).
-- MONTHNAME devuelve el nombre del mes y agrupo por eso.
SELECT MONTHNAME(payment_date) AS month, AVG(amount) AS avg_payment
FROM payment
GROUP BY month;

-- 8. Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total de alquileres).
-- El distrito sale de la dirección del cliente que alquiló: rental -> customer -> address.
SELECT a.district, COUNT(*) AS rentals
FROM rental r
JOIN customer c ON c.customer_id = r.customer_id
JOIN address a ON a.address_id = c.address_id
GROUP BY a.district
ORDER BY rentals DESC
LIMIT 10;

-- 9. Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero y representa la cantidad de copias
--    de una misma película que tiene determinada tienda. El número por defecto debería ser 5 copias.
ALTER TABLE inventory ADD COLUMN stock INT DEFAULT 5;

-- 10. Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, haga un update en la tabla
--     `inventory` restando una copia al stock de la película rentada (Hint: revisar que el rental no tiene información directa
--     sobre la tienda, sino sobre el cliente, que está asociado a una tienda en particular).
-- El rental ya trae el inventory_id (que es una copia de una película en una tienda), así que le resto 1 a esa fila.
-- NEW es la fila que se acaba de insertar en rental.
DROP TRIGGER IF EXISTS update_stock;
CREATE TRIGGER update_stock
AFTER INSERT ON rental
FOR EACH ROW
    UPDATE inventory SET stock = stock - 1 WHERE inventory_id = NEW.inventory_id;

-- 11. Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea a la tabla rental
--     y el segundo es un valor numérico con dos decimales.
DROP TABLE IF EXISTS fines;
CREATE TABLE fines (
    rental_id INT,
    amount DECIMAL(10, 2),
    FOREIGN KEY (rental_id) REFERENCES rental(rental_id)
);

-- 12. Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un registro en la tabla `fines` por cada
--     `rental` cuya devolución (return_date) haya tardado más de 3 días (comparación con rental_date).
--     El valor de la multa será el número de días de retraso multiplicado por 1.5.
-- Como el procedimiento es un solo INSERT no hace falta BEGIN/END ni cambiar el DELIMITER.
-- DATEDIFF da los días entre la devolución y el alquiler.
DROP PROCEDURE IF EXISTS check_date_and_fine;
CREATE PROCEDURE check_date_and_fine()
    INSERT INTO fines (rental_id, amount)
    SELECT rental_id, DATEDIFF(return_date, rental_date) * 1.5
    FROM rental
    WHERE DATEDIFF(return_date, rental_date) > 3;

CALL check_date_and_fine();

-- 13. Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.
DROP ROLE IF EXISTS employee, administrator, mortal_employee, boss_employee;
CREATE ROLE employee;
GRANT INSERT, DELETE, UPDATE ON sakila.rental TO employee;

-- 14. Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios sobre la BD `sakila`.
REVOKE DELETE ON sakila.rental FROM employee;
CREATE ROLE administrator;
GRANT ALL PRIVILEGES ON sakila.* TO administrator;

-- 15. Crear dos roles de empleado. A uno asignarle los permisos de `employee` y al otro de `administrator`.
-- A cada rol nuevo le doy uno de los roles anteriores y hereda sus permisos.
CREATE ROLE mortal_employee;
CREATE ROLE boss_employee;
GRANT employee TO mortal_employee;
GRANT administrator TO boss_employee;
