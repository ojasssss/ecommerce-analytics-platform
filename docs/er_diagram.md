# Data Model: Gold Layer (Star Schema)

This diagram represents the **Dimensional Model** implemented in the Gold Layer. It features a Transactional Fact Table linked to a Slowly Changing Dimension (SCD Type 2) for Products.

```mermaid
erDiagram
    %% =======================================================
    %% 1. FACT TABLE
    %% =======================================================
    gold_fact_sales {
        timestamp event_time
        date event_date "PARTITION KEY"
        int product_id FK
        int user_id "🔒 MASKED (SHA-1)"
        double transaction_amount "🔒 REDACTED (RLS)"
        string event_type "FILTER COLUMN"
        string brand
    }

    %% =======================================================
    %% 2. DIMENSION TABLE (SCD TYPE 2)
    %% =======================================================
    gold_dim_products {
        int product_id PK
        double price
        string category_code
        string brand
        boolean is_current
        timestamp __START_AT "SCD Valid From"
        timestamp __END_AT "SCD Valid To"
    }

    %% =======================================================
    %% 3. RELATIONSHIPS
    %% =======================================================
    
    %% A Product History has many Sales Events
    gold_dim_products ||--o{ gold_fact_sales : "tracks pricing for"
