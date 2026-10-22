// Práctico 9 - Ejercicio 1
// Regla de validación para la colección users: name, email y password obligatorios,
// name de hasta 30 caracteres, email con formato de mail y password de al menos 50 caracteres.
use("mflix");

// collMod modifica una colección que ya existe; acá le agrego el validador con $jsonSchema.
db.runCommand({
  collMod: "users",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "email", "password"],
      properties: {
        name: {
          bsonType: "string",
          maxLength: 30,
          description: "name es obligatorio y tiene como máximo 30 caracteres",
        },
        email: {
          bsonType: "string",
          // algo@algo.algo, con 2 a 4 letras al final
          pattern: "^(.*)@(.*)\\.(.{2,4})$",
          description: "email es obligatorio y tiene que tener formato de mail",
        },
        password: {
          bsonType: "string",
          minLength: 50,
          description: "password es obligatoria y tiene al menos 50 caracteres",
        },
      },
    },
  },
});
