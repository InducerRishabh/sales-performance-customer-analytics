/*
===============================================================================
Gold Layer: Sales Performance & Customer Analytics
===============================================================================

Purpose:
    Create business-ready analytical views from the Silver layer.

    The Gold layer follows a star-schema design:

        dim_customers
              |
              |
        fact_sales ---- dim_products

    The model is designed to support:
        - Sales performance analysis
        - Customer analysis
        - Product and category analysis
        - Gross profit estimation
        - Fulfillment / shipping analysis

Important:
    Gross profit is estimated using product unit cost from the product
    dimension:

        Estimated Gross Profit =
            Sales Amount - (Quantity * Product Cost)

    This should not be interpreted as accounting profit without confirmation
    of the underlying cost definition.
===============================================================================
*/


-- =============================================================================
-- Dimension: Customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS

SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,

    ci.cst_id              AS customer_id,
    ci.cst_key             AS customer_number,
    ci.cst_firstname       AS first_name,
    ci.cst_lastname        AS last_name,

    la.cntry               AS country,

    ci.cst_marital_status  AS marital_status,

    -- CRM is treated as the primary gender source.
    -- ERP is used as a fallback when CRM contains n/a.
    CASE
        WHEN ci.cst_gndr <> 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ca.bdate               AS birthdate,
    ci.cst_create_date     AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;

GO


-- =============================================================================
-- Dimension: Products
-- =============================================================================

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS

SELECT
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    pn.prd_id          AS product_id,
    pn.prd_key         AS product_number,
    pn.prd_nm          AS product_name,

    pn.cat_id          AS category_id,
    pc.cat             AS category,
    pc.subcat          AS subcategory,

    pc.maintenance     AS maintenance,

    pn.prd_cost        AS unit_cost,
    pn.prd_line        AS product_line,

    pn.prd_start_dt    AS start_date

FROM silver.crm_prd_info pn

LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

-- Keep the currently active product record.
WHERE pn.prd_end_dt IS NULL;

GO


-- =============================================================================
-- Fact: Sales
-- =============================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS

SELECT
    sd.sls_ord_num       AS order_number,

    pr.product_key       AS product_key,
    cu.customer_key      AS customer_key,

    sd.sls_order_dt      AS order_date,
    sd.sls_ship_dt       AS shipping_date,
    sd.sls_due_dt        AS due_date,

    sd.sls_sales         AS sales_amount,
    sd.sls_quantity      AS quantity,
    sd.sls_price         AS unit_price,

    pr.unit_cost         AS unit_cost,

    -- Estimated gross profit based on transaction quantity and product cost.
    sd.sls_sales
        - (sd.sls_quantity * pr.unit_cost)
        AS estimated_gross_profit,

    -- Profitability ratio.
    CASE
        WHEN sd.sls_sales > 0
        THEN
            (
                sd.sls_sales
                - (sd.sls_quantity * pr.unit_cost)
            ) / sd.sls_sales * 100.0
        ELSE NULL
    END AS estimated_margin_pct,

    -- Number of days between order and shipment.
    CASE
        WHEN sd.sls_order_dt IS NOT NULL
         AND sd.sls_ship_dt IS NOT NULL
        THEN DATEDIFF(
            DAY,
            sd.sls_order_dt,
            sd.sls_ship_dt
        )
        ELSE NULL
    END AS shipping_days

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;

GO