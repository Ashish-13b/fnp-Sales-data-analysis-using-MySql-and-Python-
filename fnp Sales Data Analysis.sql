-- Creating Dabase Structure --

create database fnp_sales_data;

use fnp_sales_data;

create table customers(
	customer_id varchar(5) primary key,
    customer_name varchar(50) not null,
    city varchar(50) not null,
    contact_number varchar(15) not null,
    email_id varchar(100) not null,
    gender varchar(10) not null,
    address varchar(200) not null
);

create table products(
	product_id int primary key,
    product_name varchar(50) not null,
    category varchar(50) not null,
    price float not null,
    occasion varchar(30) not null
);

create table orders(
	order_id int primary key,
    customer_id varchar(5) not null,
    product_id int not null,
    quantity int not null,
    order_date varchar(15) not null,
    order_time time not null,
    delivery_date varchar(15) not null,
    delivery_time time not null,
    foreign key(customer_id) references customers(customer_id),
    foreign key(product_id) references products(product_id)
);

-- Quering the tables

select * from customers;

select * from products;

select * from orders;

-- Transforming Data
alter table orders add column order_date2 date after order_date;

update orders set order_date2 = str_to_date(order_date, "%d-%m-%Y");

alter table orders drop column order_date;

alter table orders rename column order_date2 to order_date;

alter table orders add column delivery_date2 date after delivery_date;

update orders set delivery_date2 = str_to_date(delivery_date, "%d-%m-%Y");

alter table orders drop column delivery_date;

alter table orders rename column delivery_date2 to delivery_date;

alter table orders add column total_amount float; 

UPDATE products
        JOIN
    orders ON products.product_id = orders.product_id 
SET 
    orders.total_amount = products.price * orders.quantity;

-- Answers to find

# Q1. Find the total revenue generated across all the products.
select sum(total_amount) as 'Total Revenue Generated' from orders;

# Q2. Find the average of customers spending on products.
select round(avg(total_amount), 2) as 'Average Customer Spending' from orders;
    
# Q3. Calculate the average time taken in days for orders to deliver.
SELECT 
    ROUND(AVG(DATEDIFF(delivery_date, order_date)), 2) 
    AS 'Average Delivery Time Taken in Days'
FROM
    orders;

# Q4. Find the total revenue by morning, afternoon and evening.
SELECT 
    CASE
        WHEN HOUR(delivery_time) < 12 THEN 'Morning'
        WHEN HOUR(delivery_time) < 18 THEN 'Afternoon'
        ELSE 'Evening'
    END AS `Time Of Sale`,
    SUM(total_amount) AS 'Total Revenue'
FROM
    orders
GROUP BY `Time Of Sale`;
    
# Q5. List total revenue generated month by month.
SELECT 
    MONTHNAME(delivery_date) AS `Month Name`,
    SUM(total_amount) AS 'Total Revenue'
FROM
    orders
GROUP BY MONTHNAME(delivery_date) , MONTH(delivery_date)
ORDER BY MONTH(delivery_date);

# Q6. Calculate which product categories gave what average revenue.
SELECT 
    products.category AS 'Product Category',
    round(AVG(orders.total_amount), 2) AS 'Average Revenue'
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id
GROUP BY products.category;
        
# Q7. Determine which 10 products are giving the most revenue.
SELECT 
    products.product_name AS `Product Name`,
    SUM(orders.total_amount) AS `Total Revenue`
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id
GROUP BY `Product Name`
ORDER BY `Total Revenue` DESC
LIMIT 10;

# Q8. List which 10 cities are placing the highest number of orders.
SELECT 
    customers.city AS `Customer City`,
    COUNT(orders.order_id) AS `Number of Orders`
FROM
    customers
        JOIN
    orders ON customers.customer_id = orders.customer_id
GROUP BY `Customer City`
ORDER BY `Number of Orders` DESC
LIMIT 10;

# Q9. Compare the total revenue generated from different occasions.
SELECT 
    products.occasion AS 'Occasion',
    SUM(orders.total_amount) AS 'Total Revenue'
FROM
    products
        JOIN
    orders ON products.product_id = orders.product_id
GROUP BY products.occasion;

# Q10. Find out which products are most popular during specific occasions.
-- Using nested query
select
	*
from
	(SELECT 
		products.occasion AS 'Product Occasion',
		products.product_name AS 'Product Name',
		SUM(orders.total_amount) AS 'Total Amount',
		dense_rank() over(partition by products.occasion order by SUM(orders.total_amount) desc) 
		as Product_Rank
	FROM
		products
			JOIN
		orders ON products.product_id = orders.product_id
	GROUP BY products.occasion , products.product_name) as Popular_Products_By_Occasion
where Product_Rank <= 5;

-- Using CTE
with Popular_Products_By_Occasion as(
	SELECT 
		products.occasion AS 'Product Occasion',
		products.product_name AS 'Product Name',
		SUM(orders.total_amount) AS 'Total Amount',
		dense_rank() over(partition by products.occasion order by SUM(orders.total_amount) desc) 
		as `Product Rank`
	FROM
		products
			JOIN
		orders ON products.product_id = orders.product_id
	GROUP BY products.occasion , products.product_name
)select * from Popular_Products_By_Occasion where `Product Rank` <= 5;








