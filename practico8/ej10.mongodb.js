// Práctico 8 - Ejercicio 10
// Actores (cast) que trabajaron en varias películas dirigidas por "Jules Bass",
// con la lista de esas películas (título y año).
use("mflix");

db.movies.aggregate([
  // Solo las películas de Jules Bass.
  { $match: { directors: "Jules Bass" } },
  // Un documento por película y actor.
  { $unwind: "$cast" },
  // Agrupo por actor y junto sus películas (sin repetir).
  { $group: { _id: "$cast", movies: { $addToSet: { title: "$title", year: "$year" } } } },
  // "movies.2" existe cuando el arreglo tiene al menos 3 elementos, o sea 3 o más películas.
  // (Si querés 2 o más, cambiá el 2 por un 1.)
  { $match: { "movies.2": { $exists: true } } },
  { $project: { _id: 0, name: "$_id", movies: 1 } },
]);
