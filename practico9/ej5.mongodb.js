// Práctico 9 - Ejercicio 5
// Crear la colección userProfiles con validación: user_id (ObjectId) y language obligatorios,
// language solo puede ser English, Spanish o Portuguese, y favorite_genres es un arreglo de strings sin repetidos.
use("mflix");

// Como la colección es nueva, el validador va directo en createCollection.
db.createCollection("userProfiles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "language"],
      properties: {
        user_id: { bsonType: "objectId" },
        language: { enum: ["English", "Spanish", "Portuguese"] },
        favorite_genres: {
          bsonType: "array",
          uniqueItems: true,
          items: { bsonType: "string" },
        },
      },
    },
  },
});

// Prueba (descomentar para correrla):
// db.userProfiles.insertOne({ user_id: ObjectId(), language: "Spanish", favorite_genres: ["Drama", "Comedy"] });
// db.userProfiles.deleteMany({ language: "Spanish" });
