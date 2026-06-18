# BikeStore SQL Analysis
Proyecto de análisis SQL sobre una base de datos de una tienda de bicicletas.  
Incluye la creación del esquema, la carga de datos y un análisis exploratorio con consultas orientadas a negocio.

## Descripción
Este proyecto utiliza la base de datos `bikestoredb` para analizar información relacionada con:
- Marcas.
- Clientes.
- Pedidos.
- Productos.
- Tiendas.
- Empleados.
- Inventario.

El objetivo principal es extraer insights de negocio a partir de consultas SQL, vistas, CTEs y funciones analíticas.

## Estructura del proyecto
- `SCHEMA.sql`: creación de la base de datos y de todas las tablas.
- `DATA.sql`: carga de datos en las tablas desde archivos CSV.
- `EDA.sql`: análisis exploratorio, limpieza de datos, joins, subqueries, vistas, CTEs y consultas de negocio.

## Modelo de datos
La base de datos contiene las siguientes tablas principales:
- `brands`
- `categories`
- `stores`
- `staffs`
- `customers`
- `products`
- `stocks`
- `orders`
- `order_items`

### Relaciones principales
- `products` se relaciona con `brands` y `categories`.
- `orders` se relaciona con `customers`, `stores` y `staffs`.
- `orderitems` se relaciona con `orders` y `products`.
- `stocks` vincula `stores` con `products`.

## Objetivos del análisis
Durante el análisis se han trabajado estos puntos:

1. Reconocimiento de tablas de dimensiones y tablas de hechos.
2. Revisión de calidad de datos:
   - valores nulos,
   - duplicados,
   - fechas incorrectas,
   - valores fuera de rango.
3. Análisis con `JOIN`, subqueries y agregaciones.
4. Resolución de preguntas de negocio:
   - tiendas que más venden,
   - ticket medio por tienda,
   - categorías con mayor ingreso,
   - empleados con mejores resultados,
   - marcas con más ingresos.
5. Creación de vistas para facilitar el análisis.
6. Uso de `CTE`, funciones ventana y `CASE`.

## Ejemplos de preguntas de negocio
- ¿Qué tienda vende más?
- ¿Qué tienda genera más ingresos por ticket medio?
- ¿Qué categoría aporta más beneficio?
- ¿Qué empleado genera más ingresos?
- ¿Qué top 3 marcas generan más ingresos?

## Limpieza de datos
En el análisis se revisaron aspectos como:
- Clientes sin teléfono.
- Pedidos con fechas incoherentes.
- Valores nulos en descuentos.
- Registros duplicados.
- Valores fuera de rango en cantidades, precios y estados.

## Vistas creadas
Se incluyen vistas para simplificar el análisis:

- `vw_Sales_Detail`
- `vw_Sales_Summary`

Estas vistas permiten consultar información detallada y agregada de ventas por cliente, trabajador, tienda, producto, mes y categoría.

## Tecnologías usadas
- SQL
- MySQL Workbench
- Modelado relacional
- EDA SQL
- Vistas
- CTEs
- Funciones ventana

## Cómo ejecutar el proyecto
1. Crear la base de datos ejecutando `SCHEMA.sql`.
2. Cargar los datos con `DATA.sql`.
3. Ejecutar el análisis contenido en `EDA.sql`.

### Orden recomendado
```sql
SOURCE SCHEMA.sql;
SOURCE DATA.sql;
SOURCE EDA.sql;
```
