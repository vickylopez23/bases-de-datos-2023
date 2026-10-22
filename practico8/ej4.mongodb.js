// Práctico 8 - Ejercicio 4
// Cantidad de películas estrenadas en los años 50 (desde 1950 hasta 1959).
use("mflix");

// Cuento las películas con el año entre 1950 y 1959, ambos incluidos.
db.movies.countDocuments({ year: { $gte: 1950, $lte: 1959 } });

// Lo mismo pero con un pipeline de agregación:
db.movies.aggregate([
  { $match: { year: { $gte: 1950, $lte: 1959 } } },
  { $count: "total" },
]);
