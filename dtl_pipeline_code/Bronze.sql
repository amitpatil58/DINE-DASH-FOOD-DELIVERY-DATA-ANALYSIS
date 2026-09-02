-- Orders (incremental / streaming ingestion)
CREATE OR REFRESH STREAMING TABLE orders_bronze AS
SELECT *
FROM STREAM READ_FILES(
  '/Volumes/amit_ws/default/dinedash/orders/',
  format => 'json'
);

-- Restaurants
CREATE OR REFRESH MATERIALIZED VIEW restaurants_bronze AS
SELECT *
FROM READ_FILES(
  '/Volumes/amit_ws/default/dinedash/dim_restaurants.csv',
  format      => 'csv',
  inferSchema => true,
  header      => true
);

-- Menu items
CREATE OR REFRESH MATERIALIZED VIEW items_bronze AS
SELECT *
FROM READ_FILES(
  '/Volumes/amit_ws/default/dinedash/dim_menu_items.csv',
  format      => 'csv',
  inferSchema => true,
  header      => true
);

-- Customers
CREATE OR REFRESH MATERIALIZED VIEW customers_bronze AS
SELECT *
FROM READ_FILES(
  '/Volumes/amit_ws/default/dinedash/dim_customers.csv',
  format      => 'csv',
  inferSchema => true,
  header      => true
);

-- Delivery agents
CREATE OR REFRESH MATERIALIZED VIEW agents_bronze AS
SELECT *
FROM READ_FILES(
  '/Volumes/amit_ws/default/dinedash/dim_delivery_agents.csv',
  format      => 'csv',
  inferSchema => true,
  header      => true
);

-- Locations
CREATE OR REFRESH MATERIALIZED VIEW locations_bronze AS
SELECT *
FROM READ_FILES(
  '/Volumes/amit_ws/default/dinedash/dim_locations.csv',
  format      => 'csv',
  inferSchema => true,
  header      => true
);