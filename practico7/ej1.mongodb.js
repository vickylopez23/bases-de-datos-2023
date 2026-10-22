// Práctico 7 - Ejercicio 1
// Insertar 5 nuevos usuarios en la colección users. Para cada nuevo usuario creado,
// insertar al menos un comentario realizado por el usuario en la colección comments.
use("mflix");

// Armo la lista de usuarios una sola vez y la uso para las dos colecciones.
const nuevosUsuarios = [
  { name: "name 1", email: "name_1@example.com", password: "example123" },
  { name: "name 2", email: "name_2@example.com", password: "example123" },
  { name: "name 3", email: "name_3@example.com", password: "example123" },
  { name: "name 4", email: "name_4@example.com", password: "example123" },
  { name: "name 5", email: "name_5@example.com", password: "example123" },
];

db.users.insertMany(nuevosUsuarios);

// Un comentario por usuario, todos sobre la misma película.
// Los comentarios se asocian al usuario por nombre y email, igual que los que ya vienen en la base.
db.comments.insertMany(
  nuevosUsuarios.map((u) => ({
    name: u.name,
    email: u.email,
    movie_id: ObjectId("5a9427648b0beebeb69579cc"),
    text: "Muy buena película, la recomiendo.",
    date: new Date(),
  }))
);
