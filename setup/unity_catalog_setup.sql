-- 1. Switch to the EXISTING catalog you made in the UI
USE CATALOG ecommerce_analytics_dev;

-- 2. Create the Correct Schemas (Must have '_layer' suffix)

-- BRONZE LAYER
CREATE SCHEMA IF NOT EXISTS bronze_layer
COMMENT 'Raw ingestion layer containing events_raw table.';

-- SILVER LAYER
CREATE SCHEMA IF NOT EXISTS silver_layer
COMMENT 'Cleaned transformation layer containing events_cleaned table.';

-- GOLD LAYER
CREATE SCHEMA IF NOT EXISTS gold_layer
COMMENT 'Business aggregation layer containing customer_metrics and product_performance.';