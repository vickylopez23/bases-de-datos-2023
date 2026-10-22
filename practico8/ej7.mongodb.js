// Práctico 8 - Ejercicio 7
// Rating IMDB promedio, mínimo y máximo por año de las películas estrenadas en los años 80
// (desde 1980 hasta 1989), ordenados de mayor a menor por promedio.
use("mflix");

db.movies.aggregate([
  // Me quedo con las películas de los 80.
  { $match: { year: { $gte: 1980, $lte: 1989 } } },
  // Agrupo por año y calculo las tres cosas del rating.
  {
    $group: {
      _id: "$year",
      promedio: { $avg: "$imdb.rating" },
      minimo: { $min: "$imdb.rating" },
      maximo: { $max: "$imdb.rating" },
    },
  },
  { $sort: { promedio: -1 } },
  // Cambio el _id por un campo "year" para que se lea mejor.
  { $project: { _id: 0, year: "$_id", promedio: 1, minimo: 1, maximo: 1 } },
]);
