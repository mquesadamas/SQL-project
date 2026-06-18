CREATE DATABASE IF NOT EXISTS bike_store_db;
USE bike_store_db;

CREATE TABLE IF NOT EXISTS brands (
brand_id INT PRIMARY KEY,
brand_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS categories (
category_id INT PRIMARY KEY,
category_name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS stores (
store_id INT PRIMARY KEY,
store_name VARCHAR(255),
phone VARCHAR(50),
email VARCHAR(255),
street VARCHAR(255),
city VARCHAR(100),
state VARCHAR(100),
zip_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS staffs (
staff_id INT PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
email VARCHAR(255),
phone VARCHAR(50),
active TINYINT,
store_id INT,
manager_id INT,
FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE IF NOT EXISTS customers (
customer_id INT PRIMARY KEY,
first_name VARCHAR(100),
last_name VARCHAR(100),
phone VARCHAR(50),
email VARCHAR(255),
street VARCHAR(255),
city VARCHAR(100),
state VARCHAR(100),
zip_code VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS products (
product_id INT PRIMARY KEY,
product_name VARCHAR(255),
brand_id INT,
category_id INT,
model_year SMALLINT,
list_price DECIMAL(10,2),
FOREIGN KEY (brand_id) REFERENCES brands(brand_id),
FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE IF NOT EXISTS stocks (
store_id INT,
product_id INT,
quantity INT,
PRIMARY KEY (store_id, product_id),
FOREIGN KEY (store_id) REFERENCES stores(store_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS orders (
order_id INT PRIMARY KEY,
customer_id INT,
order_status TINYINT,
order_date DATETIME,
required_date DATETIME,
shipped_date DATETIME,
store_id INT,
staff_id INT,
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
FOREIGN KEY (store_id) REFERENCES stores(store_id),
FOREIGN KEY (staff_id) REFERENCES staffs(staff_id)
);

CREATE TABLE IF NOT EXISTS order_items (
order_id INT,
item_id INT,
product_id INT,
quantity INT,
list_price DECIMAL(10,2),
discount DECIMAL(5,2),
PRIMARY KEY (order_id, item_id),
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);

