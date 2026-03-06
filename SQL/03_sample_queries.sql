-- ============================================
-- SAMPLE SQL QUERIES FOR POWER BI DASHBOARD
-- ============================================

-- ====================
-- 1. BASIC KPIs
-- ====================

-- Total Sales, Profit, Orders, and Profit Margin
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct,
    ROUND(AVG(sales)::numeric, 2) AS avg_order_value
FROM orders;


-- ====================
-- 2. SALES TREND (Monthly)
-- ====================

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales)::numeric, 2) AS monthly_sales,
    ROUND(SUM(profit)::numeric, 2) AS monthly_profit,
    COUNT(DISTINCT order_id) AS order_count
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;


-- ====================
-- 3. SALES BY REGION
-- ====================

SELECT 
    region,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct
FROM orders
GROUP BY region
ORDER BY total_sales DESC;


-- ====================
-- 4. TOP 10 STATES BY SALES
-- ====================

SELECT 
    state,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY state
ORDER BY total_sales DESC
LIMIT 10;


-- ====================
-- 5. PRODUCT CATEGORY PERFORMANCE
-- ====================

SELECT 
    category,
    sub_category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    COUNT(*) AS units_sold,
    ROUND(AVG(discount)::numeric, 4) AS avg_discount
FROM orders
GROUP BY category, sub_category
ORDER BY total_sales DESC;


-- ====================
-- 6. TOP 10 PRODUCTS BY PROFIT (Window Function + RANK)
-- ====================

WITH product_performance AS (
    SELECT 
        product_name,
        category,
        ROUND(SUM(sales)::numeric, 2) AS total_sales,
        ROUND(SUM(profit)::numeric, 2) AS total_profit,
        SUM(quantity) AS units_sold,
        RANK() OVER (ORDER BY SUM(profit) DESC) AS profit_rank
    FROM orders
    GROUP BY product_name, category
)
SELECT 
    profit_rank,
    product_name,
    category,
    total_sales,
    total_profit,
    units_sold
FROM product_performance
WHERE profit_rank <= 10
ORDER BY profit_rank;


-- ====================
-- 7. RUNNING TOTAL OF SALES (Window Function)
-- ====================

SELECT 
    order_date,
    ROUND(SUM(sales)::numeric, 2) AS daily_sales,
    ROUND(SUM(SUM(sales)) OVER (ORDER BY order_date)::numeric, 2) AS running_total
FROM orders
GROUP BY order_date
ORDER BY order_date;


-- ====================
-- 8. YEAR-OVER-YEAR GROWTH (CTE + LAG)
-- ====================

WITH yearly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        ROUND(SUM(sales)::numeric, 2) AS total_sales,
        ROUND(SUM(profit)::numeric, 2) AS total_profit
    FROM orders
    GROUP BY EXTRACT(YEAR FROM order_date)
)
SELECT 
    year,
    total_sales,
    total_profit,
    LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales,
    ROUND(
        ((total_sales - LAG(total_sales) OVER (ORDER BY year)) / 
         NULLIF(LAG(total_sales) OVER (ORDER BY year), 0) * 100)::numeric, 
        2
    ) AS yoy_growth_pct
FROM yearly_sales
ORDER BY year;


-- ====================
-- 9. CUSTOMER SEGMENT ANALYSIS
-- ====================

SELECT 
    segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(AVG(sales)::numeric, 2) AS avg_order_value
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;


-- ====================
-- 10. RFM ANALYSIS (Recency, Frequency, Monetary)
-- ====================

WITH customer_rfm AS (
    SELECT 
        customer_id,
        customer_name,
        CURRENT_DATE - MAX(order_date) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(sales)::numeric, 2) AS monetary
    FROM orders
    GROUP BY customer_id, customer_name
)
SELECT 
    customer_id,
    customer_name,
    recency_days,
    frequency,
    monetary,
    CASE 
        WHEN frequency >= 10 AND monetary >= 5000 THEN 'VIP'
        WHEN frequency >= 7 AND monetary >= 3000 THEN 'High Value'
        WHEN frequency >= 4 AND monetary >= 1000 THEN 'Regular'
        WHEN frequency >= 2 THEN 'Occasional'
        ELSE 'New/One-time'
    END AS customer_segment
FROM customer_rfm
ORDER BY monetary DESC
LIMIT 20;


-- ====================
-- 11. MONTHLY SALES WITH PERCENTAGE OF TOTAL (Window Function)
-- ====================

WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        ROUND(SUM(sales)::numeric, 2) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    monthly_sales,
    ROUND(
        (monthly_sales / SUM(monthly_sales) OVER () * 100)::numeric, 
        2
    ) AS pct_of_total
FROM monthly_sales
ORDER BY month;


-- ====================
-- 12. DISCOUNT IMPACT ANALYSIS
-- ====================

SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.1 THEN '1-10%'
        WHEN discount <= 0.2 THEN '11-20%'
        WHEN discount <= 0.3 THEN '21-30%'
        ELSE '31%+'
    END AS discount_range,
    COUNT(*) AS order_count,
    ROUND(AVG(sales)::numeric, 2) AS avg_sales,
    ROUND(AVG(profit)::numeric, 2) AS avg_profit,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric, 2) AS profit_margin_pct
FROM orders
GROUP BY discount_range
ORDER BY discount_range;


-- ====================
-- 13. SHIP MODE ANALYSIS
-- ====================

SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(ship_date - order_date)::numeric, 1) AS avg_ship_days,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM orders
GROUP BY ship_mode
ORDER BY total_orders DESC;


-- ====================
-- 14. TOP 10 CUSTOMERS BY SALES
-- ====================

SELECT 
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(AVG(sales)::numeric, 2) AS avg_order_value
FROM orders
GROUP BY customer_id, customer_name, segment
ORDER BY total_sales DESC
LIMIT 10;


-- ====================
-- 15. QUARTERLY PERFORMANCE (Advanced CTE)
-- ====================

WITH quarterly_data AS (
    SELECT 
        DATE_TRUNC('quarter', order_date) AS quarter,
        category,
        ROUND(SUM(sales)::numeric, 2) AS sales,
        ROUND(SUM(profit)::numeric, 2) AS profit
    FROM orders
    GROUP BY DATE_TRUNC('quarter', order_date), category
)
SELECT 
    quarter,
    category,
    sales,
    profit,
    LAG(sales) OVER (PARTITION BY category ORDER BY quarter) AS prev_quarter_sales,
    ROUND(
        ((sales - LAG(sales) OVER (PARTITION BY category ORDER BY quarter)) / 
         NULLIF(LAG(sales) OVER (PARTITION BY category ORDER BY quarter), 0) * 100)::numeric,
        2
    ) AS qoq_growth_pct
FROM quarterly_data
ORDER BY quarter, category;


-- ====================
-- VERIFICATION QUERIES
-- ====================

-- Check data import
SELECT 'Total Rows' AS metric, COUNT(*) AS value FROM orders
UNION ALL
SELECT 'Date Range', CONCAT(MIN(order_date), ' to ', MAX(order_date)) FROM orders
UNION ALL
SELECT 'Total Sales', CONCAT('$', ROUND(SUM(sales)::numeric, 2)) FROM orders
UNION ALL
SELECT 'Total Profit', CONCAT('$', ROUND(SUM(profit)::numeric, 2)) FROM orders;
