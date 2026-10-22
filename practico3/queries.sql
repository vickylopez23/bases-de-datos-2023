-- Práctico 3: joins y operaciones de conjuntos sobre la base world
-- La idea es cruzar city, country y countrylanguage usando los códigos de país.
USE world;

-- 1. Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.
-- Uno cada ciudad con su país por el código y ordeno por la población de la ciudad.
SELECT ci.Name AS City, co.Name AS Country, co.Region, co.GovernmentForm
FROM city ci
JOIN country co ON ci.CountryCode = co.Code
ORDER BY ci.Population DESC
LIMIT 10;

-- 2. Listar los 10 países con menor población del mundo, junto a sus ciudades capitales
--    (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").
-- Uso LEFT JOIN para que aparezcan también los países sin capital (quedan con NULL).
SELECT co.Name AS Country, ci.Name AS Capital
FROM country co
LEFT JOIN city ci ON co.Capital = ci.ID
ORDER BY co.Population
LIMIT 10;

-- 3. Listar el nombre, continente y todos los lenguajes oficiales de cada país.
--    (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).
SELECT co.Name, co.Continent, cl.Language
FROM country co
JOIN countrylanguage cl ON cl.CountryCode = co.Code
WHERE cl.IsOfficial = 'T';

-- 4. Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.
-- Mismo LEFT JOIN que en el 2, por si algún país grande no tiene capital cargada.
SELECT co.Name AS Country, ci.Name AS Capital
FROM country co
LEFT JOIN city ci ON co.Capital = ci.ID
ORDER BY co.SurfaceArea DESC
LIMIT 20;

-- 5. Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.
-- Los idiomas están por país, así que uno la ciudad con los idiomas de su país.
SELECT ci.Name AS City, cl.Language, cl.Percentage
FROM city ci
JOIN countrylanguage cl ON cl.CountryCode = ci.CountryCode
WHERE cl.IsOfficial = 'T'
ORDER BY ci.Population DESC;

-- 6. Listar los 10 países con mayor población y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.
-- Hago las dos consultas por separado y las junto con UNION.
-- Los paréntesis son necesarios para que cada ORDER BY / LIMIT se aplique a su propia consulta.
(SELECT Name, Population FROM country ORDER BY Population DESC LIMIT 10)
UNION
(SELECT Name, Population FROM country WHERE Population >= 100 ORDER BY Population LIMIT 10);

-- 7. Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
-- Me quedo con los países que tienen inglés o francés como oficial y pido que tengan los dos (2 filas por país).
SELECT co.Name
FROM country co
JOIN countrylanguage cl ON cl.CountryCode = co.Code
WHERE cl.IsOfficial = 'T' AND cl.Language IN ('English', 'French')
GROUP BY co.Code, co.Name
HAVING COUNT(*) = 2;

-- 8. Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
-- Países con inglés, sacando los que aparecen en la lista de países con español.
SELECT co.Name
FROM country co
JOIN countrylanguage cl ON cl.CountryCode = co.Code
WHERE cl.Language = 'English'
  AND cl.Percentage > 0
  AND co.Code NOT IN (
      SELECT CountryCode
      FROM countrylanguage
      WHERE Language = 'Spanish' AND Percentage > 0
  );
