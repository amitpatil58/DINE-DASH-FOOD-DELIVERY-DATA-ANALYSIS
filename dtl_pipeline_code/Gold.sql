-- 1. Total orders per restaurant
CREATE OR REFRESH MATERIALIZED VIEW total_orders_per_restaurant AS
SELECT restaurant_name, COUNT(DISTINCT order_id) AS total_orders
FROM orders_silver
GROUP BY restaurant_name;

-- 2. Top-selling items
CREATE OR REFRESH MATERIALIZED VIEW top_selling_items AS
SELECT item_name, SUM(item_quantity) AS total_qty_sold
FROM orders_silver
GROUP BY item_name
ORDER BY total_qty_sold DESC
LIMIT 10;

-- 3. Avg restaurant rating and tip by city
CREATE OR REFRESH MATERIALIZED VIEW avg_fees_by_city AS
SELECT city, AVG(restaurant_rating) AS avg_restaurant_rating, AVG(tip) AS avg_tip
FROM orders_silver
GROUP BY city;

-- 4. Agent performance
CREATE OR REFRESH MATERIALIZED VIEW agent_order_counts AS
SELECT agent_name, COUNT(DISTINCT order_id) AS orders_handled, AVG(agent_rating) AS avg_rating
FROM orders_silver
GROUP BY agent_name
ORDER BY orders_handled DESC;

-- 5. Revenue trend
CREATE OR REFRESH MATERIALIZED VIEW daily_revenue_trend AS
SELECT DATE(order_ts) AS order_date, SUM(total_amount) AS total_revenue
FROM orders_silver
GROUP BY order_date
ORDER BY order_date;

-- 6. Customer lifetime value
CREATE OR REFRESH MATERIALIZED VIEW customer_ltv AS
SELECT customer_id, customer_name, SUM(total_amount) AS lifetime_spend
FROM orders_silver
GROUP BY customer_id, customer_name
ORDER BY lifetime_spend DESC;

-- 7. Order counts per customer
CREATE OR REFRESH MATERIALIZED VIEW customer_order_counts AS
SELECT customer_name, COUNT(*) AS total_orders
FROM orders_with_customers
GROUP BY customer_name;