-- FIX DOMAIN 1: GOVERNANCE
-- Granting basic access to all account users so they can see the project.

-- 1. Allow traversing the Catalog
GRANT USE CATALOG ON CATALOG ecommerce_analytics_dev TO `account users`;

-- 2. Allow traversing the Schemas
GRANT USE SCHEMA ON SCHEMA ecommerce_analytics_dev.gold_layer TO `account users`;
GRANT USE SCHEMA ON SCHEMA ecommerce_analytics_dev.silver_layer TO `account users`;

-- 3. Allow Reading the Data (Crucial!)
GRANT SELECT ON SCHEMA ecommerce_analytics_dev.gold_layer TO `account users`;

-- Validation:
-- After running this, go to Catalog Explorer -> ecommerce_analytics_dev -> Permissions.
-- You should see "USE CATALOG" and "SELECT" for "account users".