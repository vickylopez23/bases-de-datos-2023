/*
 * Práctico 9 - Ejercicio 6
 * Tipo de relación entre movies y comments.
 *
 * Es una relación uno a muchos: una película tiene muchos comentarios y cada comentario es de una sola película.
 * Está hecha por referencia y no con documentos anidados: cada comentario guarda el movie_id de su película.
 * Tiene sentido así porque una película puede llegar a tener muchísimos comentarios (lo que se llama one-to-squillions),
 * y meterlos todos adentro del documento de la película lo haría crecer demasiado.
 *
 * No hay una relación uno a uno entre estas dos colecciones.
 */
