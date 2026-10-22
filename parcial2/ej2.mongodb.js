// Parcial 2 - Ejercicio 2
// Ventas de la tienda de Seattle hechas en el local o por teléfono entre el 1/2/2014 y el 31/1/2015,
// con el email y la satisfacción del cliente y el monto total de cada venta.
// Ordenado por satisfacción (de mayor a menor) y después por email.
use("supplies");

db.sales.aggregate([
  {
    $match: {
      storeLocation: "Seattle",
      purchaseMethod: { $in: ["In store", "Phone"] },
      saleDate: {
        $gte: ISODate("2014-02-01T00:00:00Z"),
        $lt: ISODate("2015-02-01T00:00:00Z"), // menor estricto al 1/2/2015 = hasta el 31/1/2015 incluido
      },
    },
  },
  {
    $project: {
      _id: 0,
      customer_email: "$customer.email",
      customer_satisfaction: "$customer.satisfaction",
      // Para cada producto multiplico precio por cantidad ($map) y sumo todo ($sum).
      total_amount: {
        $sum: { $map: { input: "$items", in: { $multiply: ["$$this.price", "$$this.quantity"] } } },
      },
    },
  },
  { $sort: { customer_satisfaction: -1, customer_email: 1 } },
]);
