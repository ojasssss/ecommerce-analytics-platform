# System Architecture

This diagram illustrates the End-to-End Medallion Architecture, including Auto Loader, DLT Pipelines, and Unity Catalog Security layers.

```mermaid
graph LR
    %% ==========================================
    %% STYLES
    %% ==========================================
    classDef bronze fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef silver fill:#f3e5f5,stroke:#4a148c,stroke-width:2px;
    classDef gold fill:#fff8e1,stroke:#ff6f00,stroke-width:2px;
    classDef security fill:#ffebee,stroke:#b71c1c,stroke-dasharray: 5 5;
    classDef source fill:#e0e0e0,stroke:#616161,stroke-width:2px;
    classDef dashboard fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px;

    %% ==========================================
    %% NODES
    %% ==========================================
    subgraph Source_Layer [Source System]
        CSV_Files[("/Volumes/.../raw_landing<br/>(CSV Files)")]:::source
    end

    subgraph Bronze_Layer [Bronze Layer: Raw Ingestion]
        direction LR
        AutoLoader(Auto Loader<br/>Schema Evolution):::bronze
        Events_Raw[("events_raw<br/>(Audit Cols + Rescue Data)")]:::bronze
    end

    subgraph Silver_Layer [Silver Layer: Quality & Cleaning]
        direction LR
        Stream_Silver(Stream w/ Drop Duplicates):::silver
        Expectations{Data Quality<br/>Expectations}:::silver
        Events_Silver[("events_silver<br/>(Clean Data)")]:::silver
        Events_Quarantine[("events_quarantine<br/>(Invalid Rows)")]:::silver
    end

    subgraph Gold_Layer [Gold Layer: Star Schema]
        direction LR
        Gold_Stream(Stream Selection):::gold
        Fact_Sales[("gold_fact_sales<br/>(Transactional Fact)")]:::gold
        CDC_View(stg_products_cdc):::gold
        SCD2_Logic(DLT Apply Changes<br/>SCD Type 2):::gold
        Dim_Products[("gold_dim_products<br/>(History Tracking)")]:::gold
    end

    subgraph Security_Governance [Unity Catalog Security Wrapper]
        RLS_Policy("🛡️ Row Level Security<br/>(Filter by Event Type)"):::security
        CLS_Policy("🔒 Column Masking<br/>(Hash UserID / Redact Price)"):::security
    end

    subgraph Consumption_Layer [Business Intelligence]
        Dashboard[("📊 E-Commerce Analytics Platform<br/>(Databricks Dashboard)")]:::dashboard
    end

    %% ==========================================
    %% CONNECTIONS
    %% ==========================================
    CSV_Files --> AutoLoader
    AutoLoader --> Events_Raw

    Events_Raw --> Stream_Silver
    Stream_Silver --> Expectations
    Expectations -- "Pass" --> Events_Silver
    Expectations -- "Fail" --> Events_Quarantine

    Events_Silver --> Gold_Stream
    Gold_Stream --> Fact_Sales

    Events_Silver --> CDC_View
    CDC_View --> SCD2_Logic
    SCD2_Logic --> Dim_Products

    Fact_Sales --- RLS_Policy
    Fact_Sales --- CLS_Policy

    Fact_Sales --> Dashboard
    Dim_Products --> Dashboard
