/*
 * Natalie Benoy
 * 2-27-2022
 * u6010825
 * IS 6420 Database Theory & Design
 * Assignment 3
 */

-- 1. List the ID, name, and price for all products with a price less than or equal to the average product price.
select product_id, product_name, product_price
from product
where product_price <=
(select avg(product_price)
from product)
;

-- 2. For each product, list its ID and total quantity ordered. Products should be listed in ascending order of the product ID.
select distinct(p.product_id), sum(quantity) as total_quantity
from product p
inner join order_line ol
on p.product_id = ol.product_id 
group by p.product_id 
order by p.product_id
;

-- 3. For each product, list its ID and total quantity ordered. Products should be listed in descending order of total quantity ordered.
select distinct(p.product_id), sum(quantity) as total_quantity
from product p
inner join order_line ol
on p.product_id = ol.product_id 
group by p.product_id 
order by total_quantity desc
;

-- 4. For each product, list its ID, name and total quantity ordered. Products should be listed in ascending order of the product name.
select distinct(p.product_id), product_name, sum(quantity) as total_quantity
from product p
inner join order_line ol
on p.product_id = ol.product_id 
group by p.product_id 
order by product_name
;

-- 5. List the name for all customers, who have placed 20 or more orders. Each customer name should appear exactly once.
-- Customer names should be sorted in ascending alphabetical order.
select distinct(customer_name)
from customer c
inner join order_header oh 
on c.customer_id = oh.customer_id
group by c.customer_name 
having count(order_id) >= 20
order by customer_name asc 
;

--6. Implement the previous query using a subquery and IN adding the requirement that the customers’ orders have been placed after Nov 5, 2020.
select distinct(customer_name)
from customer c
inner join order_header oh 
on c.customer_id = oh.customer_id
where order_id in (
	select order_id
	from order_header
	where order_date > '11-05-2020')
group by c.customer_name 
having count(order_id) >= 20
order by customer_name asc 
;

-- 7. For each city, list the number of customers from that city, who have placed 5 or more orders.
-- Cities are listed in ascending alphabetical order.
select count(c.customer_id) as number_of_customers_with_5_or_more_orders, city
from customer c
inner join order_header oh
on c.customer_id = oh.customer_id 
where city is not null
group by city
having count(order_id) >= 5
order by city asc 
;

--8. Implement the previous using a subquery and IN.
select count(c.customer_id) as number_of_customers_with_5_or_more_orders, city
from customer c
inner join order_header oh
on c.customer_id = oh.customer_id 
where c.customer_id in (
	select customer_id 
	from order_header
	group by customer_id 
	having count(order_id) >= 5) and city is not null
group by city 
order by city asc 
;

-- 9. List the ID for all products, which have NOT been ordered on Nov 5, 2019 or after.
-- Sort your results by the product id in ascending order.  Use EXCEPT for this query.
select distinct(product_id)
from order_line
except
select product_id
from order_line ol
inner join order_header oh 
on ol.order_id = oh.order_id 
where order_date > '11-05-2019'
order by product_id
;

--10. List the ID for all Arizona customers, who have placed one or more orders on Nov 5, 2019 or after.
-- Sort the results by the customer id in ascending order.  Use Intersect for this query.
-- Make sure to look for alternate spellings for Arizona, like "AZ"
select distinct(customer_id)
from customer
where state_province in ('AZ', 'Arizona')
intersect
select distinct(c.customer_id)
from customer c
inner join order_header oh 
on c.customer_id = oh.customer_id
where order_date >= '11-05-2019'
order by customer_id
;

-- 11. Implement the previous query using a subquery and IN.
select distinct(customer_id)
from customer
where state_province in ('AZ', 'Arizona') and customer_id in (
	select c.customer_id
	from customer c
	inner join order_header oh 
	on c.customer_id = oh.customer_id
	where order_date >= '11-05-2019')
order by customer_id
;

-- 12. List the IDs for all California customers along with all customers (regardless where they are from)
-- who have placed one or more order(s) before Nov 5, 2020. Sort the results by the customer id in ascending order.
-- Use union for this query.
select distinct(customer_id) 
from customer
where state_province in ('CA', 'California')
union 
select distinct(c.customer_id) 
from customer c
inner join order_header oh 
on c.customer_id = oh.customer_id
where order_date < '11-05-2020'
order by customer_id
;

-- 13. List the product ID, product name and total quantity ordered for all products with total quantity ordered greater than 6.
select distinct(p.product_id), p.product_name, sum(ol.quantity) as total_quantity
from product p 
inner join order_line ol 
on p.product_id = ol.product_id
group by p.product_id, p.product_name 
having sum(ol.quantity) > 6
order by total_quantity desc
;

-- 14. List the product ID, product name  and total quantity ordered for all products
-- with total quantity ordered greater than 4 and were placed by Nevada customers.
-- Make sure to look for alternative spellings for Nevada state, such as "NV".
select distinct(p.product_id), p.product_name, sum(ol.quantity) as total_quantity
from product p 
inner join order_line ol 
on p.product_id = ol.product_id
left join order_header oh 
on ol.order_id = oh.order_id 
left join customer c 
on oh.customer_id = c.customer_id 
where state_province in ('NV', 'Nevada')
group by p.product_id, p.product_name 
having sum(ol.quantity) > 4
order by total_quantity desc
;

-- look at database information schema
select *
from information_schema.tables
where table_schema = 'public'
;

-- find tables that have the column 'customer_id'
select *
from information_schema.columns c
join information_schema.tables t 
on c.table_name = t.table_name 
and c.table_schema = t.table_schema 
and c.table_catalog = t.table_catalog 
where column_name like '%customer%id%'
;

