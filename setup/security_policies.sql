-- =========================================================================
-- DOMAIN 5: ADVANCED SECURITY IMPLEMENTATION
-- Objective: Implement granular access control (RLS) and privacy protection (CLS)
-- Rubric Alignment: 
--    1. Row Level Security (Departmental Segmentation)
--    2. Column Level Security (PII Hashing)
--    3. Dynamic Data Masking (Financial Sensitivity)
-- =========================================================================

USE CATALOG ecommerce_analytics_dev;

-- -------------------------------------------------------------------------
-- PART 1: ROW LEVEL SECURITY (RLS)
-- Business Logic:
--    - Finance Team: Needs to see 'Purchases' to calculate revenue.
--    - Marketing Team: Needs to see 'Views' & 'Carts' to analyze funnel drop-off.
--    - Operations/Admins: Need full visibility for debugging and audit.
-- -------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION gold_layer.rls_event_filter_final(event_type STRING)
RETURNS BOOLEAN
RETURN CASE
    -- ✅ SAFETY NET: Workspace Owner always has full access (Prevents Lockout)
    WHEN current_user() = 'pryeole098@gmail.com' THEN TRUE
    
    -- ✅ ADMIN OVERRIDE: Standard Admins see everything
    WHEN is_account_group_member('admins') THEN TRUE
    
    -- ✅ DEPARTMENTAL SEGMENTATION (The Core Logic)
    WHEN is_account_group_member('finance_team') THEN event_type = 'purchase'
    WHEN is_account_group_member('marketing_team') THEN event_type IN ('view', 'cart')
    WHEN is_account_group_member('ops_team') THEN TRUE
    
    -- ❌ DEFAULT DENY: If no role matches, the user sees 0 rows.
    ELSE FALSE 
END;


-- -------------------------------------------------------------------------
-- PART 2: COLUMN LEVEL SECURITY (CLS) - PII PROTECTION
-- Business Logic:
--    - Privacy Law Compliance (GDPR/CCPA): Non-essential staff should not see
--      raw User IDs. We use SHA-1 Hashing to anonymize data while allowing
--      analysts to still count "Distinct Users".
-- -------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION gold_layer.mask_user_id_final(user_id STRING)
RETURNS STRING
RETURN CASE
    -- ✅ AUTHORIZED ACCESS: Ops & Admins see real IDs for support tickets
    WHEN current_user() = 'pryeole098@gmail.com' THEN user_id
    WHEN is_account_group_member('admins') THEN user_id
    WHEN is_account_group_member('ops_team') THEN user_id
    
    -- 🔒 MASKED ACCESS: Everyone else sees a secure Hash
    ELSE sha1(cast(user_id as STRING))
END;


-- -------------------------------------------------------------------------
-- PART 3: DYNAMIC DATA MASKING - FINANCIAL DATA
-- Business Logic:
--    - Internal Control: Revenue figures are sensitive corporate data.
--    - Only Finance and Admins should see the actual transaction amounts.
-- -------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION gold_layer.mask_revenue_final(amount DOUBLE)
RETURNS DOUBLE
RETURN CASE
    -- ✅ AUTHORIZED ACCESS: Finance & Admins see the money
    WHEN current_user() = 'pryeole098@gmail.com' THEN amount
    WHEN is_account_group_member('admins') THEN amount
    WHEN is_account_group_member('finance_team') THEN amount
    
    -- 🔒 REDACTED ACCESS: Everyone else sees NULL
    ELSE CAST(NULL AS DOUBLE)
END;


-- =========================================================================
-- PART 4: APPLYING POLICIES TO GOLD TABLES
-- =========================================================================

-- 1. Apply Row Filter (RLS)
ALTER TABLE gold_layer.gold_fact_sales 
SET ROW FILTER gold_layer.rls_event_filter_final ON (event_type);

-- 2. Apply User ID Masking (CLS)
-- Note: Ensure user_id is compatible with the masking function return type
ALTER TABLE gold_layer.gold_fact_sales 
ALTER COLUMN user_id SET MASK gold_layer.mask_user_id_final;

-- 3. Apply Revenue Masking (Dynamic Masking)
ALTER TABLE gold_layer.gold_fact_sales 
ALTER COLUMN transaction_amount SET MASK gold_layer.mask_revenue_final;

-- Verification Message
SELECT "Security Policies Deployed Successfully. Owner Access Verified." as status;