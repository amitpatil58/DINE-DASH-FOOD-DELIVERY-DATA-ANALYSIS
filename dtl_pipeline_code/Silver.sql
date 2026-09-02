CREATE OR REFRESH STREAMING TABLE cleaned_orders (
  CONSTRAINT valid_order_id EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_customer EXPECT (customer_id IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_items    EXPECT (size(items_ordered) > 0) ON VIOLATION DROP ROW
)
AS
SELECT
    order_id, timestamp AS order_ts, customer_id, restaurant_id, agent_id, delivery_location_id, items_ordered, total_amount, tip, payment_method, order_status
FROM STREAM(orders_bronze);

CREATE OR REFRESH STREAMING TABLE orders_silver (
  CONSTRAINT valid_restaurant_name EXPECT (restaurant_name IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_agent          EXPECT (agent_name IS NOT NULL)      ON VIOLATION DROP ROW,
  CONSTRAINT valid_item           EXPECT (item_id IS NOT NULL)         ON VIOLATION DROP ROW
)
AS
SELECT sub.order_id, sub.order_ts, sub.customer_id, sub.customer_name, sub.email, sub.restaurant_id, sub.restaurant_name, sub.cuisines, sub.restaurant_rating, sub.agent_id, sub.agent_name, sub.agent_rating, sub.delivery_location_id, sub.city, sub.item_id, i.item_name, i.category, sub.item_price, sub.item_quantity, sub.total_amount, sub.tip, sub.payment_method, sub.order_status
FROM (
  SELECT o.order_id, o.order_ts, o.customer_id, c.name AS customer_name, c.email, o.restaurant_id, r.name AS restaurant_name, r.cuisines, r.rating AS restaurant_rating, o.agent_id, a.name AS agent_name, a.rating AS agent_rating, o.delivery_location_id, l.city, item.item_id AS item_id, item.price AS item_price, item.quantity AS item_quantity, o.total_amount, o.tip, o.payment_method, o.order_status
  FROM STREAM(cleaned_orders) o
  LEFT JOIN customers_bronze   c ON o.customer_id = c.customer_id
  LEFT JOIN restaurants_bronze r ON o.restaurant_id = r.restaurant_id
  LEFT JOIN agents_bronze      a ON o.agent_id = a.agent_id
  LEFT JOIN locations_bronze   l ON o.delivery_location_id = l.location_id
  LATERAL VIEW EXPLODE(o.items_ordered) AS item
) sub
LEFT JOIN items_bronze i ON sub.item_id = i.item_id;

CREATE OR REFRESH STREAMING TABLE orders_with_agents AS
SELECT o.order_id, o.order_ts, o.agent_id, a.name AS agent_name, a.rating AS agent_rating, o.tip
FROM STREAM(cleaned_orders) o
LEFT JOIN agents_bronze a ON o.agent_id = a.agent_id;

CREATE OR REFRESH STREAMING TABLE orders_with_items AS
SELECT o.order_id, o.order_ts, o.restaurant_id, exploded.item_id, i.item_name, i.category, exploded.price, exploded.quantity
FROM (
  SELECT order_id, timestamp AS order_ts, restaurant_id, EXPLODE(items_ordered) AS exploded
  FROM STREAM(orders_bronze)
) o
LEFT JOIN items_bronze i ON o.exploded.item_id = i.item_id;

CREATE OR REFRESH STREAMING TABLE orders_with_locations AS
SELECT o.order_id, o.order_ts, o.delivery_location_id, l.city, l.state, l.area
FROM STREAM(cleaned_orders) o
LEFT JOIN locations_bronze l ON o.delivery_location_id = l.location_id;

CREATE OR REFRESH STREAMING TABLE orders_with_customers AS
SELECT o.order_id, o.customer_id, c.name AS customer_name, c.location_id AS customer_location_id, o.total_amount, o.tip, o.payment_method, o.order_status
FROM STREAM(cleaned_orders) o
LEFT JOIN customers_bronze c ON o.customer_id = c.customer_id;