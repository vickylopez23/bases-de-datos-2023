// Parcial 2 - Ejercicio 3
// Vista salesInvoiced con lo facturado por mes y año: mínimo, máximo, promedio y total,
// ordenada del mes más reciente al más viejo.
use("supplies");

const pipeline = [
  // Primero calculo cuánto se cobró en cada venta: precio * cantidad de cada producto, sumado.
  {
    $addFields: {
      charged: {
        $sum: { $map: { input: "$items", in: { $multiply: ["$$this.price", "$$this.quantity"] } } },
      },
    },
  },
  // Agrupo por año y mes de la venta.
  {
    $group: {
      _id: { year: { $year: "$saleDate" }, month: { $month: "$saleDate" } },
      minimo: { $min: "$charged" },
      maximo: { $max: "$charged" },
      promedio: { $avg: "$charged" },
      total: { $sum: "$charged" },
    },
  },
  { $project: { _id: 0, year: "$_id.year", month: "$_id.month", minimo: 1, maximo: 1, promedio: 1, total: 1 } },
  { $sort: { year: -1, month: -1 } },
];

// Si la vista ya existía la borro, así el archivo se puede volver a correr.
db.salesInvoiced.drop();
db.createView("salesInvoiced", "sales", pipeline);

db.salesInvoiced.find();
