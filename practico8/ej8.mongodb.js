// Práctico 8 - Ejercicio 8
// Título, año y cantidad de comentarios de las 10 películas con más comentarios.
use("mflix");

db.comments.aggregate([
  // Cuento los comentarios de cada película y ordeno de mayor a menor.
  { $sortByCount: "$movie_id" },
  { $limit: 10 },
  // Busco la película de cada grupo para sacar el título y el año (es como un JOIN).
  { $lookup: { from: "movies", localField: "_id", foreignField: "_id", as: "movie" } },
  // $lookup devuelve un arreglo; como es una sola película lo desarmo para acceder directo.
  { $unwind: "$movie" },
  { $project: { _id: 0, title: "$movie.title", year: "$movie.year", comments: "$count" } },
]);
