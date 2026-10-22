-- Práctico 6: vistas, procedimientos, funciones, triggers y roles sobre la base classicmodels
-- Para ubicarse: un empleado (employees) atiende clientes (customers.salesRepEmployeeNumber),
-- los clientes hacen órdenes (orders) y cada orden tiene su detalle de productos (orderdetails).
USE classicmodels;

-- 1. Devuelva la oficina con mayor número de empleados.
-- Cuento empleados por oficina y me quedo con la primera.
SELECT officeCode, COUNT(*) AS employees
FROM employees
GROUP BY officeCode
ORDER BY employees DESC
LIMIT 1;

-- 2. ¿Cuál es el promedio de órdenes hechas por oficina?, ¿Qué oficina vendió la mayor cantidad de productos?
-- Primero armo una vista con la cantidad de órdenes de cada oficina (a través de los clientes de sus empleados)...
CREATE OR REPLACE VIEW offices_orders_amount AS
SELECT e.officeCode, COUNT(DISTINCT o.orderNumber) AS orders
FROM employees e
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON o.customerNumber = c.customerNumber
GROUP BY e.officeCode;

-- ...y el promedio sale de esa vista.
SELECT AVG(orders) AS avg_orders_per_office
FROM offices_orders_amount;

-- Para la segunda pregunta sumo las unidades vendidas (quantityOrdered) por oficina y me quedo con la mayor.
SELECT e.officeCode, SUM(od.quantityOrdered) AS products_sold
FROM employees e
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders o ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = o.orderNumber
GROUP BY e.officeCode
ORDER BY products_sold DESC
LIMIT 1;

-- 3. Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.
-- Agrupo los pagos por el número de mes y muestro el mes para saber a cuál corresponde cada fila.
SELECT MONTH(paymentDate) AS month,
       AVG(amount) AS avg_payment,
       MAX(amount) AS max_payment,
       MIN(amount) AS min_payment
FROM payments
GROUP BY month
ORDER BY month;

-- 4. Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.
-- Los parámetros llevan "p_" adelante para no confundirlos con las columnas de la tabla.
-- Al ser una sola sentencia no hace falta BEGIN/END ni DELIMITER.
DROP PROCEDURE IF EXISTS update_credit;
CREATE PROCEDURE update_credit(IN p_customer INT, IN p_credit DECIMAL(10, 2))
    UPDATE customers SET creditLimit = p_credit WHERE customerNumber = p_customer;

-- Ejemplo de uso:
-- CALL update_credit(103, 25000);

-- 5. Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma.
--    La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.
CREATE OR REPLACE VIEW premium_customers AS
SELECT c.customerName, c.city, SUM(p.amount) AS total_spent
FROM customers c
JOIN payments p ON p.customerNumber = c.customerNumber
GROUP BY c.customerNumber, c.customerName, c.city
ORDER BY total_spent DESC
LIMIT 10;

-- 6. Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido)
--    cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.
-- La función devuelve directamente el resultado de un SELECT: cuento las órdenes de ese mes por empleado y me quedo con el primero.
DROP FUNCTION IF EXISTS employee_of_the_month;
CREATE FUNCTION employee_of_the_month(p_month INT, p_year INT)
RETURNS VARCHAR(255)
READS SQL DATA
RETURN (
    SELECT CONCAT(e.firstName, ' ', e.lastName)
    FROM employees e
    JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
    JOIN orders o ON o.customerNumber = c.customerNumber
    WHERE MONTH(o.orderDate) = p_month AND YEAR(o.orderDate) = p_year
    GROUP BY e.employeeNumber, e.firstName, e.lastName
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- Ejemplo: el empleado del mes de febrero de 2003
SELECT employee_of_the_month(2, 2003);

-- 7. Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products"
--    y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.
-- La relación varios a uno es la clave foránea a products: muchos pedidos de reposición para un mismo producto.
DROP TABLE IF EXISTS product_refillment;
CREATE TABLE product_refillment (
    refillmentID INT AUTO_INCREMENT PRIMARY KEY,
    productCode VARCHAR(15),
    orderDate DATE,
    quantity INT,
    FOREIGN KEY (productCode) REFERENCES products(productCode)
);

-- 8. Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue
--    una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`)
--    y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.
-- En vez de usar IF, el INSERT ... SELECT solo inserta algo cuando se cumple la condición del WHERE
-- (que lo que queda en stock después del pedido sea menor a 10).
DROP TRIGGER IF EXISTS restock_product;
CREATE TRIGGER restock_product
AFTER INSERT ON orderdetails
FOR EACH ROW
    INSERT INTO product_refillment (productCode, orderDate, quantity)
    SELECT NEW.productCode, CURDATE(), 10
    FROM products
    WHERE productCode = NEW.productCode
      AND quantityInStock - NEW.quantityOrdered < 10;

-- Para probarlo (el producto S24_2000 tiene poco stock):
-- INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) VALUES (10123, 'S24_2000', 10, 0, 0);
-- SELECT * FROM product_refillment;

-- 9. Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas.
DROP ROLE IF EXISTS Empleado;
CREATE ROLE Empleado;
GRANT SELECT, CREATE VIEW ON classicmodels.* TO Empleado;

-- Consultas adicionales (más difíciles, opcionales). Quedaron sin resolver:
-- Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia en días entre las fechas
-- de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.

-- Encontrar el nombre y la cantidad vendida total de los 10 productos más vendidos que, a su vez, representen al menos el 4% del total
-- de productos, contando unidad por unidad, de todas las órdenes donde intervienen. No utilizar LIMIT.
