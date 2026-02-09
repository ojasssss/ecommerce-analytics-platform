-- =========================================================================
-- DOMAIN 1: GOVERNANCE & CATALOG SETUP
-- Purpose: Initialize the Unity Catalog structure and apply basic access control.
-- =========================================================================

-- 1. Switch to the Catalog
USE CATALOG ecommerce_analytics_dev;

-- 2. Create the Schemas (Must be done BEFORE granting access)
-- BRONZE LAYER
CREATE SCHEMA IF NOT EXISTS bronze_layer
COMMENT 'Raw ingestion layer containing events_raw table.';

-- SILVER LAYER
CREATE SCHEMA IF NOT EXISTS silver_layer
COMMENT 'Cleaned transformation layer containing events_cleaned table.';

-- GOLD LAYER
CREATE SCHEMA IF NOT EXISTS gold_layer
COMMENT 'Business aggregation layer containing customer_metrics and product_performance.';


-- 3. APPLY GOVERNANCE (Permissions)
-- Granting basic access to all account users so they can traverse the project.

-- Allow traversing the Catalog
GRANT USE CATALOG ON CATALOG ecommerce_analytics_dev TO `account users`;

-- Allow traversing the Schemas
GRANT USE SCHEMA ON SCHEMA ecommerce_analytics_dev.gold_layer TO `account users`;
GRANT USE SCHEMA ON SCHEMA ecommerce_analytics_dev.silver_layer TO `account users`;

-- Allow Reading the Data (Crucial!)
GRANT SELECT ON SCHEMA ecommerce_analytics_dev.gold_layer TO `account users`;

-- Validation:
-- After running this, go to Catalog Explorer -> ecommerce_analytics_dev -> Permissions.
-- You should see "USE CATALOG" and "SELECT" for "account users".