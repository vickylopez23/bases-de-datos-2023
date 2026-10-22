// Práctico 8 - Ejercicio 2
// Cantidad de estados con al menos dos cines (theaters) registrados.
use("mflix");

// Es lo mismo que el ejercicio 1, pero después me quedo con los estados que tienen 2 o más cines
// y cuento cuántos estados quedaron.
db.theaters.aggregate([
  { $group: { _id: "$location.address.state", count: { $sum: 1 } } },
  { $match: { count: { $gte: 2 } } },
  { $count: "total" },
]);
