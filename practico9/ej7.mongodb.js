/*
 * Práctico 9 - Ejercicio 7
 * Diseño de un esquema para una librería (libros, categorías, pedidos y detalle de pedidos).
 *
 * Tomamos como "consulta eficiente" la que se puede responder con una sola query, sin $lookup.
 * El esquema sale de las consultas que hay que hacer:
 *
 * Query 1: id, título y precio de los libros de un autor, con sus categorías.
 *   -> Cada libro lleva su categoría adentro, como documento anidado. Así sale todo de books.
 *
 * Query 2: cantidad de libros por categoría.
 *   -> Con la categoría adentro del libro es un $group directo sobre books.
 *
 * Query 3: nombre y dirección de entrega y monto total (quantity * price) de un pedido dado.
 *   -> Depende de cuántos ítems pueda tener un pedido:
 *      - Pocos (digamos menos de 1000): los meto anidados en el pedido. Mil ítems no se acercan al límite de 16 MB por documento.
 *      - Muchos (hasta unos 100.000): en el pedido guardo solo referencias (ObjectId de 12 bytes); 12 B * 100.000 sigue entrando en 16 MB.
 *      - Muchísimos: cada ítem guarda el id de su pedido (referencia al padre). Es lo más lento pero no tiene límite.
 *
 * Elegimos la primera opción, ítems anidados, porque es la más eficiente. Si un pedido tuviera más de 1000 ítems
 * se podría partir en varios pedidos.
 */

use("shop");

// Libros, con la categoría anidada.
db.createCollection("books", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["book_id", "title", "author"],
      properties: {
        book_id: { bsonType: "int" },
        title: { bsonType: "string" },
        author: { bsonType: "string" },
        price: { bsonType: "decimal" },
        category: {
          bsonType: "object",
          required: ["category_id", "category_name"],
          properties: {
            category_id: { bsonType: "int" },
            category_name: { bsonType: "string" },
          },
        },
      },
    },
  },
});

// Pedidos, con sus ítems anidados en el arreglo "orders" (el detalle del pedido).
db.createCollection("orders", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["order_id", "delivery_name", "delivery_address", "cc_name", "cc_number", "cc_expiry"],
      properties: {
        order_id: { bsonType: "long" },
        delivery_name: { bsonType: "string" },
        delivery_address: { bsonType: "string" },
        cc_name: { bsonType: "string" },
        cc_number: { bsonType: "string" },
        cc_expiry: { bsonType: "string" },
        orders: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["id", "book_id", "title", "author", "quantity", "price", "order_id"],
            properties: {
              id: { bsonType: "long" },
              book_id: { bsonType: "int" },
              title: { bsonType: "string" },
              author: { bsonType: "string" },
              quantity: { bsonType: "int" },
              price: { bsonType: "decimal" },
              order_id: { bsonType: "long" },
            },
          },
        },
      },
    },
  },
});

// Ejemplo de cómo sale la query 3 con este esquema (un solo documento, sin $lookup):
// db.orders.aggregate([
//   { $match: { order_id: NumberLong(1) } },
//   { $project: {
//       delivery_name: 1,
//       delivery_address: 1,
//       total: { $sum: { $map: { input: "$orders", in: { $multiply: ["$$this.quantity", "$$this.price"] } } } },
//   } },
// ]);
