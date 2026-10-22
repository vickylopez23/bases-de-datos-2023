// Parcial 2 - Ejercicio 4
// Para cada tienda: la venta promedio, el objetivo de la tienda (de storeObjectives) y la diferencia entre los dos.
use("supplies");

db.sales.aggregate([
  // Monto de cada venta: precio * cantidad de cada producto, sumado.
  {
    $addFields: {
      charged: {
        $sum: { $map: { input: "$items", in: { $multiply: ["$$this.price", "$$this.quantity"] } } },
      },
    },
  },
  // Promedio de venta por tienda.
  { $group: { _id: "$storeLocation", avg_charged: { $avg: "$charged" } } },
  // Traigo el objetivo de la tienda. En storeObjectives el _id es el nombre de la tienda.
  { $lookup: { from: "storeObjectives", localField: "_id", foreignField: "_id", as: "objective" } },
  // Cada tienda tiene un solo objetivo, así que desarmo el arreglo que devuelve $lookup.
  { $unwind: "$objective" },
  {
    $project: {
      _id: 0,
      storeLocation: "$_id",
      venta_promedio: "$avg_charged",
      objetivo: "$objective.objective",
      diferencia: { $subtract: ["$avg_charged", "$objective.objective"] },
    },
  },
]);
