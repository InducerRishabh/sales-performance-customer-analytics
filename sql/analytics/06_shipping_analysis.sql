USE DataWarehouse;
GO

/* ============================================================
   06 - SHIPPING & DELIVERY ANALYSIS
   ============================================================ */


/* ============================================================
   1. Overall Shipping Performance
   ============================================================ */

SELECT
    COUNT(DISTINCT order_number) AS total_orders,

    AVG(CAST(shipping_days AS DECIMAL(10,2)))
        AS avg_shipping_days,

    MIN(shipping_days) AS min_shipping_days,

    MAX(shipping_days) AS max_shipping_days,

    SUM(
        CASE
            WHEN shipping_days <= 3 THEN 1
            ELSE 0
        END
    ) AS orders_shipped_within_3_days,

    CAST(
        SUM(
            CASE
                WHEN shipping_days <= 3 THEN 1
                ELSE 0
            END
        ) * 100.0
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS pct_within_3_days

FROM gold.fact_sales
WHERE shipping_days IS NOT NULL;


/* ============================================================
   2. Shipping Performance by Year
   ============================================================ */

SELECT
    YEAR(shipping_date) AS shipping_year,

    COUNT(DISTINCT order_number) AS total_orders,

    AVG(CAST(shipping_days AS DECIMAL(10,2)))
        AS avg_shipping_days,

    MIN(shipping_days) AS min_shipping_days,

    MAX(shipping_days) AS max_shipping_days,

    SUM(
        CASE
            WHEN shipping_days <= 3 THEN 1
            ELSE 0
        END
    ) AS orders_within_3_days

FROM gold.fact_sales

WHERE shipping_date IS NOT NULL
  AND shipping_days IS NOT NULL

GROUP BY
    YEAR(shipping_date)

ORDER BY
    shipping_year;


/* ============================================================
   3. Shipping Speed Distribution
   ============================================================ */

SELECT
    CASE
        WHEN shipping_days <= 2 THEN '0-2 Days'
        WHEN shipping_days <= 5 THEN '3-5 Days'
        WHEN shipping_days <= 10 THEN '6-10 Days'
        ELSE '10+ Days'
    END AS shipping_bucket,

    COUNT(DISTINCT order_number) AS total_orders,

    SUM(quantity) AS total_units_sold,

    SUM(sales_amount) AS total_revenue,

    AVG(CAST(shipping_days AS DECIMAL(10,2)))
        AS avg_shipping_days

FROM gold.fact_sales

WHERE shipping_days IS NOT NULL

GROUP BY
    CASE
        WHEN shipping_days <= 2 THEN '0-2 Days'
        WHEN shipping_days <= 5 THEN '3-5 Days'
        WHEN shipping_days <= 10 THEN '6-10 Days'
        ELSE '10+ Days'
    END

ORDER BY
    MIN(shipping_days);


/* ============================================================
   4. Shipping Performance by Product Line
   ============================================================ */

SELECT
    dp.product_line,

    COUNT(DISTINCT fs.order_number) AS total_orders,

    AVG(CAST(fs.shipping_days AS DECIMAL(10,2)))
        AS avg_shipping_days,

    SUM(fs.quantity) AS total_units_sold,

    SUM(fs.sales_amount) AS total_revenue

FROM gold.fact_sales fs

LEFT JOIN gold.dim_products dp
    ON fs.product_key = dp.product_key

WHERE fs.shipping_days IS NOT NULL

GROUP BY
    dp.product_line

ORDER BY
    avg_shipping_days;


/* ============================================================
   5. Late Shipping Orders
   ============================================================ */

SELECT TOP 20

    order_number,
    order_date,
    shipping_date,
    due_date,
    shipping_days,
    sales_amount,
    quantity

FROM gold.fact_sales

WHERE shipping_days > 10

ORDER BY
    shipping_days DESC;