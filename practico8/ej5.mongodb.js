// Práctico 8 - Ejercicio 5
// Listar los 10 géneros con mayor cantidad de películas.
use("mflix");

// Cada película tiene un arreglo de géneros, así que primero lo "desarmo" con $unwind
// (queda un documento por película y género). Después $sortByCount agrupa por género,
// cuenta y ordena de mayor a menor en un solo paso.
db.movies.aggregate([
  { $unwind: "$genres" },
  { $sortByCount: "$genres" },
  { $limit: 10 },
]);
