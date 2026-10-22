// Práctico 8 - Ejercicio 3
// Cantidad de películas dirigidas por "Louis Lumière".
use("mflix");

// directors es un arreglo, y en Mongo comparar un arreglo con un valor
// busca si ese valor está adentro. Así que alcanza con contar los documentos que lo tengan.
db.movies.countDocuments({ directors: "Louis Lumière" });

// Lo mismo pero con un pipeline de agregación:
db.movies.aggregate([
  { $match: { directors: "Louis Lumière" } },
  { $count: "total" },
]);
