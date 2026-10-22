-- Práctico 2: consultas básicas sobre la base world
-- Acá solo se usa SELECT con ORDER BY, LIMIT y WHERE, nada de joins todavía.
USE world;

-- 1. Devuelva una lista de los nombres y las regiones a las que pertenece cada país ordenada alfabéticamente.
-- Con ordenar por nombre alcanza, no hace falta ordenar también por región.
SELECT Name, Region
FROM country
ORDER BY Name;

-- 2. Liste el nombre y la población de las 10 ciudades más pobladas del mundo.
-- Ordeno de mayor a menor población y me quedo con las primeras 10.
SELECT Name, Population
FROM city
ORDER BY Population DESC
LIMIT 10;

-- 3. Liste el nombre, región, superficie y forma de gobierno de los 10 países con menor superficie.
-- Igual que la anterior pero al revés: ordeno de menor a mayor superficie.
SELECT Name, Region, SurfaceArea, GovernmentForm
FROM country
ORDER BY SurfaceArea
LIMIT 10;

-- 4. Liste todos los países que no tienen independencia.
-- Los que no tienen año de independencia cargado son los que nunca se independizaron.
SELECT Name
FROM country
WHERE IndepYear IS NULL;

-- 5. Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas declarados oficiales.
-- En IsOfficial los oficiales están marcados con 'T'.
SELECT Language, Percentage
FROM countrylanguage
WHERE IsOfficial = 'T';
