// Práctico 9 - Ejercicio 2
// Ver la regla de validación que quedó en la colección users.
use("mflix");

// getCollectionInfos muestra la información de la colección, y ahí adentro (en options.validator) está el esquema.
db.getCollectionInfos({ name: "users" });
