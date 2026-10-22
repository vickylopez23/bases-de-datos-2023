// Práctico 8 - Ejercicio 9
// Crear una vista con los 5 géneros con mayor cantidad de comentarios, junto con la cantidad de comentarios.
use("mflix");

// La idea: cuento comentarios por película, traigo los géneros de cada película
// y sumo esos conteos por género.
const pipeline = [
  { $sortByCount: "$movie_id" },
  { $lookup: { from: "movies", localField: "_id", foreignField: "_id", as: "movie" } },
  { $unwind: "$movie" },
  // Una película puede tener varios géneros: los separo para que sus comentarios cuenten en cada uno.
  { $unwind: "$movie.genres" },
  { $group: { _id: "$movie.genres", comments: { $sum: "$count" } } },
  { $sort: { comments: -1 } },
  { $limit: 5 },
];

// Si la vista ya existía la borro, así se puede volver a correr el archivo.
db.top5genrespercomments.drop();
db.createView("top5genrespercomments", "comments", pipeline);

db.top5genrespercomments.find();
