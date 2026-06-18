USE bike_store_db;

/*========================================================
1. RECONOCIMENTO DE LAS TABLAS DE DIMENSIONES A UTILIZAR
========================================================== */

SELECT table_name, table_rows
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY table_rows DESC;

/* Vemos las tablas que tienen más filas, así podemos entenderlas un poco más. 
Order_items se refiere a los elementos de cada pedido mientras que orders a los pedidos en sí, 
stocks a la cantidad almacenada de cada producto y el resto es intuitivo por el nombre de la tabla. */


SELECT * FROM brands;
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM order_items;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM staffs;
SELECT * FROM stocks;
SELECT * FROM stores;

/* Aquí hacemos una comprobación rápida de las tablas para ver un poco por encima lo que representan
y que además a simple vista no se vean muchos valores nulos. Como vista principal vemos que de la tabla de
customers, vemos que de una gran cantidad de clientes no contamos con el número de teléfono. Si es de importancia,
más adelante veremos qué podemos hacer para remediarlo. 

Tabla Brands: vemos el id de la marca y las posibles marcas de bicicletas con las que trabaja la empresa.
Tabla Categories: vemos el id de la categoría y los posibles tipos de bicicleta con los que trabaja la empresa.
Tabla Customers: vemos el nombre y apellido de los clientes y otras características como el email, número de teléfono y dónde viven.
Tabla Products: vemos el nombre de las bicis, el año del modelo, el precio y a qué categoría y marca pertenecen por el ID.
Tabla Staffs: vemos el nombre de los trabajadores, el email del trabajo, número de teléfono, vemos que trabajan todos y el ID de la tineda y del manager.
Tabla Stores: vemos el nombre de las tiendas, el número telefónico, email y dirección exacta.
Tabla Stocks: vemos la cantidad de productos que tienen almacenados en cada tienda y de cada producto por sus IDs. 
*/

/*========================================================
2. RECONOCIMENTO DE LA(S) TABLA(S) DE HECHOS A UTILIZAR
========================================================== */

SELECT 
	oi.*,
	o.*
FROM order_items oi
LEFT JOIN orders o ON o.order_id = oi.order_id;

/* La fact table más adecuada es order_items, porque contiene el nivel más granular de la transacción, es decir, 
cada línea de pedido con producto, cantidad, precio y descuento. La tabla orders se usa como contexto complementario 
para añadir información del pedido, como fecha, cliente, tienda y estado. Por eso, al unir ambas tablas se obtiene
 la base principal del análisis de ventas del modelo estrella. */
 
 /*==========================================================
3. ANÁLISIS DE LA CALIDAD DE LOS DATOS (NULOS, OUTLIERS...)
============================================================ */

/* ==============================================================
   VISUALIZACIÓN DE ALGUNOS VALORES NULOS (SABIENDO QUE NO HAY)
 ================================================================ */

SELECT COUNT(*) AS null_phone
FROM customers
WHERE phone IS NULL;

SELECT COUNT(*) AS null_email
FROM customers
WHERE email IS NULL;

SELECT COUNT(*) AS null_order_date
FROM orders
WHERE order_date IS NULL;

SELECT COUNT(*) AS null_discount
FROM order_items
WHERE discount IS NULL;

-- CORRECCIÓN DE NULOS
SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET phone = 'NO NUMBER'
WHERE phone IS NULL;

UPDATE order_items
SET discount = 0
WHERE discount IS NULL;
SET SQL_SAFE_UPDATES = 1;

select phone from customers; -- Comprobamos que ya no hay nulos en phone y que pone NO NUMBER


/*=======================================
COMPROBAMOS SI HAY REGISTROS DUPLICADOS
========================================= */

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- No encontramos duplicados.


/*=====================================
COMPROBAMOS SI HAY FECHAS INCORRECTAS
======================================= */

SELECT *
FROM orders
WHERE order_date > CURRENT_DATE(); -- No hay fechas superiores a la actual en los registros

SELECT *
FROM orders
WHERE required_date < order_date; -- No hay fechas de pedido superiores a las de deseo de entrega

SELECT *
FROM orders
WHERE shipped_date < order_date; -- No hay fechas de pedido superiores a las de envío


/*========================================
COMPROBAMOS SI HAY VALORES FUERA DE RANGO
========================================== */

SELECT *
FROM order_items
WHERE quantity <= 0;

SELECT *
FROM order_items
WHERE list_price < 0;

SELECT *
FROM order_items
WHERE discount < 0 OR discount > 1;

SELECT *
FROM staffs
WHERE active NOT IN (0, 1);

-- No encontramos valores fuera de rango


 /*===================================================
4. PRIMEROS JOINs & SUBQUERIES & CÁLCULO DE MÉTRICAS
====================================================== */

SELECT 
*,
(list_price * quantity * (1 - discount)) as final_price
FROM order_items;

/* En esta query podemos ver el valor final de cada item incluyendo el pedido*/


SELECT 
	order_id,
    customer_id,
    SUM(final_price) AS order_price
FROM (SELECT 
		oi.*,
		o.customer_id,
		(list_price * quantity * (1 - discount)) as final_price
	FROM order_items oi
	LEFT JOIN orders o ON oi.order_id = o.order_id) AS Tabla
GROUP BY order_id, customer_id
ORDER BY order_price DESC;

/* con esta query con subquery podemos ver los pedidos totales ordenados por el desembolso final, ordenados
de mayor a menor gasto y el ID del consumidor que lo realizo */


Select 
    customer_id,
    SUM(final_price) AS order_price
FROM (SELECT 
		oi.*,
		o.customer_id,
		(list_price * quantity * (1 - discount)) as final_price
	FROM order_items oi
	LEFT JOIN orders o ON oi.order_id = o.order_id) AS Tabla
GROUP BY customer_id
ORDER BY order_price DESC
LIMIT 10;

/* Ahora con esto podemos ver el ranking (TOP 10) de los clientes que más han gastado en total*/

SELECT 
	c.customer_id,
    CONCAT(first_name," ",last_name) as complete_name,
    o.order_id
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id;

/* En esta query con LEFT JOIN podemos ver el ID del cliente, su nombre completo y los pedidos que ha realizado. 
Usamos el LEFT JOIN por si diera el caso de que no hay algún pedido registrado a ningún cliente, que nos lo dé. */


SELECT 
	o.order_id,
    o.product_id,
    quantity,
    product_name,
    o.list_price,
    o.discount,
    (o.list_price * o.quantity * (1-discount)) AS final_price
FROM order_items o
JOIN products p ON p.product_id = o.product_id
ORDER BY order_id, product_id;
    
/* En esta consulta vemos como complementamos la tabla de order_items con la de products, para poder ver el nombre de
los productos que se compran en cada compra, el precio, el descuento, la cantidad y el precio final de compra.
Además, los ordenamos para que aparezcan los primeros order_id al principio y dentro de cada uno, según el product_id */


 /*===============================
5. PRIMERAS PREGUNTAS DE NEGOCIO
================================== */
-- ¿¿¿QUÉ TIENDAS VENDEN MÁS???
SELECT 
	st.store_id,
    store_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM stores st 
JOIN orders o ON st.store_id = o.store_id
GROUP BY st.store_id, store_name
ORDER BY total_orders DESC;

/* Aquí vemos que la tienda de Baldwin Bikes es la que más vende con diferencia, pero ¿es la tienda que más dinero gana? */


SELECT 
	st.store_id,
    store_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount,
	(SUM(oi.list_price * oi.quantity * (1-discount)) / COUNT(DISTINCT o.order_id)) AS ticket_medio
FROM stores st 
JOIN orders o ON st.store_id = o.store_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY st.store_id, store_name
ORDER BY ticket_medio DESC;

/* Ahora comprobamos que el ticket medio por venta nos dice que la mejor tienda sería la 3a aunque sea la que menos gane
y que sea la que menos venta realiza, pero vemos como aunque sean menos venta, promedian +200€ y +350€ por cada venta.
Tal vez la mejor idea sería conseguir incentivar el consumo en la tienda Rowlett Bikes porque parece que los clientes
pueden llegar a dejarse más dinero de promedio... */

-- =======================================================================================================================

-- ¿¿¿QUÉ CATEGORÍA GENERA MÁS INGRESOS???
SELECT 
	c.category_id,
    category_name,
	SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount
FROM categories c 
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY c.category_id, category_name
ORDER BY total_amount DESC;

/* Aquí podemos ver que las bicis para niños son las que menos dinero dan a la empresa, mientras que las 
bicis de montaña son la fuente principal de ingresos para la empresa. */

-- ========================================================================================================================

-- ¿¿¿QUÉ EMPLEADO GENERA MÁS INGRESOS???
SELECT 
	s.staff_id,
    s.store_id,
    CONCAT(s.first_name, " ", s.last_name) AS complete_name,
	SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount
FROM staffs s
JOIN orders o ON s.staff_id = o.staff_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY s.staff_id, s.store_id
ORDER BY total_amount DESC;

/* Aquí vemos que los mejores vendedores son los que corresponden con las tiendas que más venden*/

-- =======================================================================================================================
-- ¿¿¿QUÉ TOP3 MARCAS GENERAN MÁS INGRESOS???
SELECT 
	b.brand_id,
    b.brand_name,
	SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN brands b ON b.brand_id = p.brand_id
GROUP BY b.brand_id, b.brand_name
ORDER BY total_amount DESC
LIMIT 3;

/* Aquí vemos que la marca Trek es la que más beneficios aporta a la empresa sin duda alguna, aunque estaría bien
tener una tabla con el coste de cada producto, para ver si el margen de beneficio es mayor en otras marcas. */
 
-- =======================================================================================================================

/*============
6. VISTAS
============== */

-- VISTA PARA CONSEGUIR AGRUPAR DETALLES DE VENTA
CREATE OR REPLACE VIEW vw_sales_detail AS
SELECT
	CONCAT(c.first_name, " ", c.last_name) AS customer_name,
	CONCAT(s.first_name, " ", s.last_name) AS staff_name,
	st.store_name,
	p.product_name,
    oi.quantity,
	SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
JOIN stores st ON st.store_id = o.store_id
JOIN staffs s ON s.staff_id = o.staff_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY customer_name, staff_name, st.store_name, p.product_name, quantity
ORDER BY total_amount DESC;

SELECT * FROM vw_sales_detail;  -- Comprobamos que funciona. 

/* En esta vista conseguimos agrupar por cliente, trabajador, tienda, producto y cantidades para ver qué clientes,
trabajadores, tiendas y producto son aquellos que registran más beneficios para la empresa. */

-- ========================================================================================================================
-- VISTA PARA CONSEGUIR AGRUPAR VENTAS AGREGADAS
CREATE OR REPLACE VIEW vw_sales_summary AS
SELECT 
	YEAR(o.order_date) AS año,
    MONTH(o.order_date) AS mes,
    st.store_name,
    c.category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
	SUM(oi.quantity) AS total_quantity,
	SUM(oi.list_price * oi.quantity) AS total_without_discount,
	SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount,
    (SUM(oi.list_price * oi.quantity * (1-discount)) / SUM(oi.quantity)) AS ticket_medio
FROM orders o 
JOIN stores st ON st.store_id = o.store_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories c ON c.category_id = p.category_id
GROUP BY año, mes, st.store_name, c.category_name
ORDER BY total_amount DESC;

SELECT * FROM vw_sales_summary; -- Comprobamos que funciona.

/* En esta vista conseguimos agrupar por año, mes, tienda y categoría, las cantidades sin descuento, con descuento 
y el ticket medio que generan. Lo ordenamos todo por el gasto sin descuento y así podemos ver los mejores meses, tiendas
y categorías de cada año respecto a ingresos */


/*=======================================================
7. CTE: Uso del WITH y FUNCIONES VENTANA (RANK() OVER())
========================================================= */

WITH ventas_cliente AS (
	SELECT
		c.customer_id,
		SUM(oi.list_price * oi.quantity * (1-discount)) AS total_amount
	FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id
	HAVING total_amount > 15000
)
SELECT 
	customer_id,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS ranking
FROM ventas_cliente;

/* Con esta query con CTE lo que conseguimos es ver el ranking de los clientes (por su ID) que más hayan gastado
en total, usamos alguna técnica de filtraje como el HAVING que actúa como un WHERE en caso de que haya una
agrupación (en este caso como usamos el GROUP BY, debemos aplicarlo). */


/*=======================================================
8. USO DE OTRAS FUNCIONES NO UTILIZADAS HASTA EL MOMENTO
========================================================= */

SELECT 
	required_date,
    shipped_date,
    CASE
		WHEN required_date > shipped_date THEN "descontento"
        WHEN required_date < shipped_date THEN "sorprendido"
        WHEN required_date = shipped_date THEN "contento"
	END AS estado_cliente
FROM orders;

/* Aquí usamos el case para analizar el estado del cliente referente a la entrega del pedido */

-- ========================================================================================================================
