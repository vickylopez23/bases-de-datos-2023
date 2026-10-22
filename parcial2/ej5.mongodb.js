// Parcial 2 - Ejercicio 5
// Regla de validación para la colección sales y dos pruebas: una venta que la cumple y otra que no.
// Nota: armé el esquema completo de la venta, con más campos de los que pedía el enunciado.
use("supplies");

db.runCommand({
  collMod: "sales",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["saleDate", "items", "storeLocation", "customer", "couponUsed", "purchaseMethod"],
      properties: {
        saleDate: { bsonType: "date" },
        // Tiene que venir al menos un producto, y cada uno con nombre, etiquetas, precio y cantidad (mínimo 1).
        items: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["name", "tags", "price", "quantity"],
            properties: {
              name: { bsonType: "string" },
              tags: { bsonType: "array" },
              price: { bsonType: "decimal" },
              quantity: { bsonType: "int", minimum: 1 },
            },
          },
        },
        storeLocation: { bsonType: "string" },
        // La satisfacción no la pongo como obligatoria, pero si viene tiene que estar entre 1 y 5.
        customer: {
          bsonType: "object",
          required: ["email", "age", "gender"],
          properties: {
            // Misma expresión regular que usamos en el práctico para validar mails.
            email: { bsonType: "string", pattern: "^(.*)@(.*)\\.(.{2,4})$" },
            age: { bsonType: "int", minimum: 6 },
            gender: { enum: ["M", "F"] },
            satisfaction: { bsonType: "int", minimum: 1, maximum: 5 },
          },
        },
        couponUsed: { bsonType: "bool" },
        // Los métodos de compra que aparecen en los datos.
        purchaseMethod: { enum: ["Online", "Phone", "In store"] },
      },
    },
  },
});

// Prueba que tiene que andar: una venta válida. Después la borro.
db.sales.insertOne({
  storeLocation: "SomeUnknownLocation",
  saleDate: ISODate("2023-01-01T13:05:00Z"),
  items: [{ name: "NASA", tags: [], price: Decimal128("123132.231"), quantity: 1 }],
  customer: { age: 21, gender: "M", email: "someemail@mail.com", satisfaction: 5 },
  couponUsed: true,
  purchaseMethod: "Online",
});
db.sales.deleteOne({ storeLocation: "SomeUnknownLocation" });

// Prueba que tiene que fallar: el email no tiene formato de mail.
db.sales.insertOne({
  storeLocation: "SomeUnknownLocation",
  saleDate: ISODate("2023-01-01T13:05:00Z"),
  items: [{ name: "NASA", tags: [], price: Decimal128("123132.231"), quantity: 1 }],
  customer: { age: 21, gender: "M", email: "wrongemail", satisfaction: 5 },
  couponUsed: true,
  purchaseMethod: "Online",
});
