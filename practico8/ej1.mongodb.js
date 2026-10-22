// Práctico 8 - Ejercicio 1
// Cantidad de cines (theaters) por estado.
use("mflix");

// Agrupo los cines por el estado de su dirección, cuento cuántos hay en cada uno
// y ordeno de mayor a menor.
db.theaters.aggregate([
  { $group: { _id: "$location.address.state", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
]);
