# Bases de Datos — FaMAF (UNC) 2023

Prácticos y parciales de la materia Bases de Datos de la Licenciatura en Ciencias de la Computación (FaMAF, UNC).
La primera parte de la materia es SQL (MySQL) y la segunda, MongoDB.

Cada archivo tiene el enunciado de cada ejercicio comentado arriba de su respuesta.

## Contenido

| Carpeta | Base | Tema |
|---------|------|------|
| `practico2/` | world | Consultas básicas: `SELECT`, `WHERE`, `ORDER BY`, `LIMIT` |
| `practico3/` | world | Joins (`INNER`, `LEFT`) y operaciones de conjuntos (`UNION`) |
| `practico4/` | world | Subconsultas (`IN`, `EXISTS`, `ALL`), `GROUP BY` y `HAVING` |
| `practico5/` | sakila | `CREATE`/`ALTER TABLE`, `UPDATE`, triggers, procedimientos y roles |
| `practico6/` | classicmodels | Vistas, procedimientos, funciones, triggers y roles |
| `parcial1/` | olympics | Parcial 1 de SQL |
| `practico7/` | mflix | Inserción de documentos en MongoDB |
| `practico8/` | mflix | Pipelines de agregación (`$group`, `$unwind`, `$lookup`, vistas) |
| `practico9/` | mflix / shop | Validación de esquemas (`$jsonSchema`) y modelado de datos |
| `parcial2/` | supplies | Parcial 2 de MongoDB |

Los archivos `.sql` grandes (`world-data.sql`, `sakila-*.sql`, `classicmodels.sql`, `olympics-*.sql`) y las carpetas
`mflix/`, `restaurantdb/` y `parcial2/supplies/` son los datos que da la cátedra para cargar las bases.

## Cómo levantar las bases

Usé Docker para no instalar nada. Los comandos están en `comousar.txt`.

**MySQL** (prácticos 2 a 6 y parcial 1):

```sh
docker compose -f docker-compose.yaml.mysql up -d
docker compose -f docker-compose.yaml.mysql exec mysql bash
mysql -uroot -padmin < /app/practico2/schema.sql
mysql -uroot -padmin < /app/practico2/world-data.sql
```

**MongoDB** (prácticos 7 a 9 y parcial 2):

```sh
docker compose up -d
docker compose exec mongo bash
mongorestore --gzip --db mflix /app/mflix
mongorestore --db supplies /app/parcial2/supplies
```

Los archivos `.mongodb.js` se pueden correr desde la extensión de MongoDB para VS Code.
