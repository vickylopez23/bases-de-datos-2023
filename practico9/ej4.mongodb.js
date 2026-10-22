// Práctico 9 - Ejercicio 4
// Regla de validación para movies: title y year obligatorios, year entre 1900 y 3000,
// y cast, directors, countries y genres como arreglos de strings sin repetidos.
use("mflix");

// Los cuatro arreglos tienen la misma regla, así que la escribo una vez y la reuso.
const arregloDeStringsSinRepetir = {
  bsonType: "array",
  uniqueItems: true,
  items: { bsonType: "string" },
};

db.runCommand({
  collMod: "movies",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "year"],
      properties: {
        title: { bsonType: "string" },
        year: { bsonType: "int", minimum: 1900, maximum: 3000 },
        cast: arregloDeStringsSinRepetir,
        directors: arregloDeStringsSinRepetir,
        countries: arregloDeStringsSinRepetir,
        genres: arregloDeStringsSinRepetir,
      },
    },
  },
});

// Prueba: una película válida (NumberInt para que el año se guarde como int y no como double).
db.movies.insertOne({
  title: "Some Movie",
  year: NumberInt(1900),
  directors: ["Test1", "Test2"],
});

db.movies.deleteMany({ title: "Some Movie" });
