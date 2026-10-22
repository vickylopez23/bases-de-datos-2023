// Parcial 2 - Ejercicio 1
// Ventas de las tiendas de London, Austin o San Diego, hechas a clientes mayores de edad,
// que tengan al menos un producto de 1000 o más con la etiqueta "kids" o "school".
// Muestra el id de la venta, la fecha, la tienda y el email del cliente.
use("supplies");

db.sales.find(
  {
    storeLocation: { $in: ["London", "Austin", "San Diego"] },
    "customer.age": { $gte: 18 },
    // $elemMatch hace que las dos condiciones se cumplan en el MISMO producto,
    // y no una en un producto y otra en otro.
    items: {
      $elemMatch: {
        price: { $gte: NumberDecimal("1000") },
        tags: { $in: ["kids", "school"] },
      },
    },
  },
  // Segundo parámetro de find: qué campos mostrar.
  {
    _id: 0,
    sale: "$_id",
    saleDate: 1,
    storeLocation: 1,
    customer_email: "$customer.email",
  }
);
