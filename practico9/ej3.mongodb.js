// Práctico 9 - Ejercicio 3
// Regla de validación para theaters: theaterId y location obligatorios, la dirección con sus campos,
// y si viene geo, que sea un punto con dos coordenadas.
// Con validationAction "warn" los documentos que no cumplen igual se guardan, pero queda una advertencia en el log.
use("mflix");

db.runCommand({
  collMod: "theaters",
  validationAction: "warn",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["theaterId", "location"],
      properties: {
        theaterId: { bsonType: "int" },
        location: {
          bsonType: "object",
          required: ["address"],
          properties: {
            address: {
              bsonType: "object",
              required: ["street1", "city", "state", "zipcode"],
              properties: {
                street1: { bsonType: "string" },
                city: { bsonType: "string" },
                state: { bsonType: "string" },
                zipcode: { bsonType: "string" },
              },
            },
            // geo no es obligatorio, pero si está tiene que tener tipo y dos coordenadas.
            geo: {
              bsonType: "object",
              required: ["type", "coordinates"],
              properties: {
                type: { enum: ["Point", null] },
                coordinates: {
                  bsonType: "array",
                  minItems: 2,
                  maxItems: 2,
                  items: { bsonType: "double" },
                },
              },
            },
          },
        },
      },
    },
  },
});

// Prueba: inserto un cine que cumple el esquema y después lo borro.
db.theaters.insertOne({
  theaterId: 51,
  location: {
    address: { street1: "Test", city: "Test", state: "Test", zipcode: "Test" },
    geo: { type: "Point", coordinates: [2.01, 3.2] },
  },
});

db.theaters.deleteMany({ theaterId: 51 });
