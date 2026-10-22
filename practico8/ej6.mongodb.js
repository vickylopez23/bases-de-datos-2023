// Práctico 8 - Ejercicio 6
// Ranking de usuarios por cantidad de comentarios (nombre, email y cantidad de comentarios).
use("mflix");

// Agrupo los comentarios por email (que identifica al usuario), me quedo con el nombre
// y cuento cuántos comentarios hizo cada uno. Después ordeno de mayor a menor.
db.comments.aggregate([
  { $group: { _id: "$email", name: { $first: "$name" }, comments: { $sum: 1 } } },
  { $sort: { comments: -1 } },
]);
