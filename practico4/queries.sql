-- Práctico 4: subconsultas, agrupaciones y funciones de agregación sobre la base world
USE world;

-- 1. Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población menor a 10000 habitantes.
-- No hace falta subconsulta: uno ciudad con país y filtro por la población del país.
SELECT ci.Name AS City, co.Name AS Country
FROM city ci
JOIN country co ON ci.CountryCode = co.Code
WHERE co.Population < 10000;

-- 2. Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.
-- La subconsulta calcula el promedio una sola vez y comparo cada ciudad contra ese número.
SELECT Name
FROM city
WHERE Population > (SELECT AVG(Population) FROM city);

-- 3. Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.
-- "Mayor o igual a algún país de Asia" es lo mismo que mayor o igual al país asiático con menos gente.
SELECT ci.Name
FROM city ci
JOIN country co ON ci.CountryCode = co.Code
WHERE co.Continent <> 'Asia'
  AND ci.Population >= (SELECT MIN(Population) FROM country WHERE Continent = 'Asia');

-- 4. Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno de los idiomas oficiales del país.
-- Para cada idioma no oficial pido que su porcentaje le gane a TODOS los oficiales de ese mismo país (por eso ALL).
SELECT co.Name, cl.Language
FROM country co
JOIN countrylanguage cl ON cl.CountryCode = co.Code
WHERE cl.IsOfficial = 'F'
  AND cl.Percentage > ALL (
      SELECT cl2.Percentage
      FROM countrylanguage cl2
      WHERE cl2.CountryCode = co.Code AND cl2.IsOfficial = 'T'
  );

-- 5. Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país)
--    al menos una ciudad con más de 100000 habitantes.
--    (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).

-- Con subquery: para cada país chico me fijo si existe alguna ciudad grande suya.
SELECT DISTINCT co.Region
FROM country co
WHERE co.SurfaceArea < 1000
  AND EXISTS (
      SELECT 1 FROM city ci
      WHERE ci.CountryCode = co.Code AND ci.Population > 100000
  );

-- Sin subquery: uno países con sus ciudades y filtro las dos condiciones juntas.
-- El DISTINCT saca las regiones repetidas.
SELECT DISTINCT co.Region
FROM country co
JOIN city ci ON ci.CountryCode = co.Code
WHERE co.SurfaceArea < 1000 AND ci.Population > 100000;

-- 6. Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada.
--    (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas escalares o usando agrupaciones, encontrar ambas).

-- Con agrupación: agrupo las ciudades por país y me quedo con la población máxima.
SELECT co.Name, MAX(ci.Population) AS MaxCityPopulation
FROM country co
JOIN city ci ON ci.CountryCode = co.Code
GROUP BY co.Code, co.Name;

-- Con consulta escalar: para cada país busco el máximo con una subconsulta que devuelve un solo valor.
-- Saco los países sin ciudades (quedarían en NULL) para que dé lo mismo que la versión con GROUP BY.
SELECT co.Name,
       (SELECT MAX(ci.Population) FROM city ci WHERE ci.CountryCode = co.Code) AS MaxCityPopulation
FROM country co
HAVING MaxCityPopulation IS NOT NULL;

-- 7. Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio de hablantes de los lenguajes oficiales.
-- Comparo cada idioma no oficial contra el promedio de los oficiales de su mismo país.
SELECT co.Name, cl.Language
FROM country co
JOIN countrylanguage cl ON cl.CountryCode = co.Code
WHERE cl.IsOfficial = 'F'
  AND cl.Percentage > (
      SELECT AVG(cl2.Percentage)
      FROM countrylanguage cl2
      WHERE cl2.CountryCode = co.Code AND cl2.IsOfficial = 'T'
  );

-- 8. Listar la cantidad de habitantes por continente ordenado en forma descendente.
SELECT Continent, SUM(Population) AS Population
FROM country
GROUP BY Continent
ORDER BY Population DESC;

-- 9. Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una esperanza de vida entre 40 y 70 años.
-- El filtro va en HAVING porque se aplica sobre el promedio, que existe recién después de agrupar.
SELECT Continent, AVG(LifeExpectancy) AS AvgLifeExpectancy
FROM country
GROUP BY Continent
HAVING AvgLifeExpectancy BETWEEN 40 AND 70;

-- 10. Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
SELECT Continent,
       MAX(Population) AS MaxPopulation,
       MIN(Population) AS MinPopulation,
       AVG(Population) AS AvgPopulation,
       SUM(Population) AS TotalPopulation
FROM country
GROUP BY Continent;
