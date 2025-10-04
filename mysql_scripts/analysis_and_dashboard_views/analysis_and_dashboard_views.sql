-- ====================================================================
-- 1. KPI & SUMMARY VIEWS
-- High-level metrics for a business overview dashboard.
-- ====================================================================

-- View: Key Performance Indicators (KPIs)
CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT "Total Sales" AS Measure ,SUM(TotalAmount) AS MeasureValue FROM fact_sales
UNION ALL
SELECT "Total Units" ,SUM(Quantity)  FROM fact_sales
UNION ALL
SELECT "Customers No" ,COUNT(CustomerKey) FROM dim_customers
UNION ALL
SELECT "Total Orders" ,COUNT(DISTINCT InvoiceNo)  FROM fact_sales
UNION ALL
SELECT "AVG Order Value" , ROUND(SUM(TotalAmount)/ COUNT(DISTINCT InvoiceNo),2) FROM fact_sales;

-- View: Sales Date Range
CREATE OR REPLACE VIEW vw_sales_date_range AS
SELECT
    MIN(InvoiceDate) AS FirstOrderDate,
    MAX(InvoiceDate) AS LastOrderDate,
    DATEDIFF(MAX(InvoiceDate),MIN(InvoiceDate)) AS SalesPeriodDays
FROM fact_sales;

-- ====================================================================
-- 2. CUSTOMER ANALYSIS VIEWS
-- Views focused on customer demographics and behavior.
-- ====================================================================

-- View: Customer Distribution by Country
CREATE OR REPLACE VIEW vw_customer_distribution_by_country AS
SELECT
    Country,
    COUNT(CustomerKey) AS CustomersNo,
    ROUND( COUNT(CustomerKey)/SUM(COUNT(CustomerKey)) OVER() * 100 ,2) AS CustomersPercentage
FROM dim_customers
GROUP BY Country;

-- View: Sales by Country
CREATE OR REPLACE VIEW vw_sales_by_country AS
SELECT
    c.Country,
    SUM(s.TotalAmount) AS TotalSales,
    ROUND( SUM(s.TotalAmount)/SUM(SUM(s.TotalAmount)) OVER() * 100 ,2) AS SalesPercentage
FROM dim_customers c
JOIN fact_sales s USING (CustomerID)
GROUP BY Country;

-- View: Top 10 Customers by Order Count
CREATE OR REPLACE VIEW vw_top_10_customers_by_orders AS
SELECT
    c.CustomerKey,
    COUNT(DISTINCT s.InvoiceNo) AS OrdersNO
FROM dim_customers c
JOIN fact_sales s USING (CustomerID)
GROUP BY CustomerKey
ORDER BY OrdersNO DESC
LIMIT 10;

-- ====================================================================
-- 3. PRODUCT ANALYSIS VIEWS
-- Views focused on product and category performance.
-- ====================================================================

-- View: Sales by Product Category
CREATE OR REPLACE VIEW vw_sales_by_product_category AS
SELECT
    p.Category,
    SUM(s.TotalAmount) AS TotalSales,
    ROUND( SUM(s.TotalAmount)/SUM(SUM(s.TotalAmount)) OVER() * 100 ,2) AS SalesPercentage
From dim_products p
JOIN fact_sales s USING(ProductID)
GROUP BY Category;

-- View: Sales by Product
CREATE OR REPLACE VIEW vw_sales_by_product AS
SELECT
    p.Product,
    SUM(s.TotalAmount) AS TotalSales,
    ROUND( SUM(s.TotalAmount)/SUM(SUM(s.TotalAmount)) OVER() * 100 ,2) AS SalesPercentage
From dim_products p
JOIN fact_sales s USING(ProductID)
GROUP BY Product;

-- View: Units Sold by Product
CREATE OR REPLACE VIEW vw_units_sold_by_product AS
SELECT
    p.Product,
    SUM(s.Quantity) AS TotalUnits,
    ROUND( SUM(s.Quantity)/SUM(SUM(s.Quantity)) OVER() * 100 ,2) AS UnitsPercentage
From dim_products p
JOIN fact_sales s USING(ProductID)
GROUP BY Product;

-- ====================================================================
-- 4. SHIPMENT & OPERATIONS VIEWS
-- Views analyzing logistics and order details.
-- ====================================================================

-- View: Order Count by Payment Method
CREATE OR REPLACE VIEW vw_orders_by_payment_method AS
SELECT
    sh.PaymentMethod,
    COUNT(DISTINCT InvoiceNo) AS OrdersNO,
    ROUND( COUNT(InvoiceNo)/SUM(COUNT(InvoiceNo)) OVER() * 100 ,2) AS PaymentMethodPercentage
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY PaymentMethod;

-- View: Order Count by Sales Channel
CREATE OR REPLACE VIEW vw_orders_by_sales_channel AS
SELECT
    sh.SalesChannel,
    COUNT(DISTINCT InvoiceNo) AS OrdersNO,
    ROUND( COUNT(InvoiceNo)/SUM(COUNT(InvoiceNo)) OVER() * 100 ,2) AS ChannelPercentage
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY SalesChannel;

-- View: Order Count by Return Status
CREATE OR REPLACE VIEW vw_orders_by_return_status AS
SELECT
    sh.ReturnStatus,
    COUNT(DISTINCT InvoiceNo) AS OrdersNO,
    ROUND( COUNT(InvoiceNo)/SUM(COUNT(InvoiceNo)) OVER() * 100 ,2) AS ReturnStatusPercentage
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY ReturnStatus;

-- View: Order Count by Shipment Provider
CREATE OR REPLACE VIEW vw_orders_by_shipment_provider AS
SELECT
    sh.ShipmentProvider,
    COUNT(DISTINCT InvoiceNo) AS OrdersNO,
    ROUND( COUNT(InvoiceNo)/SUM(COUNT(InvoiceNo)) OVER() * 100 ,2) AS ShipmentProviderPercentage
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY ShipmentProvider;

-- View: Order Count by Warehouse Location
CREATE OR REPLACE VIEW vw_orders_by_warehouse_location AS
SELECT
    sh.WarehouseLocation,
    COUNT(DISTINCT InvoiceNo) AS OrdersNO,
    ROUND( COUNT(InvoiceNo)/SUM(COUNT(InvoiceNo)) OVER() * 100 ,2) AS WarehouseLocationPercentage
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY WarehouseLocation;

-- View: Order Count by Priority
CREATE OR REPLACE VIEW vw_orders_by_priority AS
SELECT
    sh.OrderPriority,
    COUNT(DISTINCT InvoiceNo) AS OrdersNO,
    ROUND( COUNT(InvoiceNo)/SUM(COUNT(InvoiceNo)) OVER() * 100 ,2) AS OrderPriorityPercentage
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY OrderPriority;

-- View: Returns vs. Non-Returns by Sales Channel
CREATE OR REPLACE VIEW vw_returns_by_sales_channel AS
SELECT
    SalesChannel,
    SUM(CASE WHEN ReturnStatus="Not Returned" THEN  1 ELSE 0 END) AS `Not Returned`,
    SUM(CASE WHEN ReturnStatus="Returned" THEN 1 ELSE 0 END) AS `Returned`
FROM dim_shipment sh
JOIN fact_sales s USING(ShipmentID)
GROUP BY SalesChannel;

-- ====================================================================
-- 5. TIME-SERIES ANALYSIS VIEWS
-- Views for analyzing trends over time.
-- ====================================================================

-- View: Sales by Year
CREATE OR REPLACE VIEW vw_sales_by_year AS
SELECT
    YEAR(InvoiceDate) AS `Year`,
    SUM(TotalAmount) AS TotalAmount,
    ROUND( SUM(TotalAmount)/SUM(SUM(TotalAmount)) OVER() * 100 ,2) AS SalesPercentage
FROM fact_sales
GROUP BY YEAR(InvoiceDate);

-- View: Sales by Month
CREATE OR REPLACE VIEW vw_sales_by_month AS
SELECT
    MONTH(InvoiceDate) AS `Month`,
    SUM(TotalAmount) AS TotalAmount,
    ROUND( SUM(TotalAmount)/SUM(SUM(TotalAmount)) OVER() * 100 ,2) AS SalesPercentage
FROM fact_sales
GROUP BY MONTH(InvoiceDate);

-- View: Sales by Quarter
CREATE OR REPLACE VIEW vw_sales_by_quarter AS
SELECT
    QUARTER(InvoiceDate) AS `Quarter`,
    SUM(TotalAmount) AS TotalAmount,
    ROUND( SUM(TotalAmount)/SUM(SUM(TotalAmount)) OVER() * 100 ,2) AS SalesPercentage
FROM fact_sales
GROUP BY QUARTER(InvoiceDate);

-- View: Running Total Sales and Quantity by Year
CREATE OR REPLACE VIEW vw_running_total_by_year AS
SELECT
    `Year`,
    TotalAmount,
    Quantity,
    SUM(TotalAmount) OVER(ORDER BY `Year`) AS running_total_sales,
    SUM(Quantity) OVER(ORDER BY `Year`) AS running_total_quantities
FROM(
    SELECT
        YEAR(InvoiceDate) AS `Year`,
        ROUND(SUM(TotalAmount)) AS TotalAmount,
        SUM(Quantity) AS Quantity
    FROM fact_sales
    GROUP BY YEAR(InvoiceDate)
)t;

-- ====================================================================
-- 6. ADVANCED PERFORMANCE ANALYSIS VIEW
-- A detailed view for product performance year-over-year.
-- ====================================================================

CREATE OR REPLACE VIEW vw_product_performance_analysis AS
SELECT
    Year,
    Product,
    CurrentSales,
    AVG(CurrentSales) OVER( PARTITION BY Product) AS AvgSales,
    CurrentSales - AVG(CurrentSales) OVER( PARTITION BY Product) AS AvgDiff,
    CASE
        WHEN CurrentSales - AVG(CurrentSales) OVER( PARTITION BY Product) > 0 THEN 'Above Average'
        WHEN CurrentSales - AVG(CurrentSales) OVER( PARTITION BY Product) < 0 THEN 'Below Average'
        ELSE 'Avg'
    END AS AvgChange,
    LAG(CurrentSales) OVER(PARTITION BY Product ORDER BY `Year`) AS PySales,
    CurrentSales - LAG(CurrentSales) OVER(PARTITION BY Product ORDER BY `Year`) AS PySalesDiff,
    CASE
        WHEN CurrentSales - LAG(CurrentSales) OVER(PARTITION BY Product ORDER BY `Year`) > 0 THEN 'Increase'
        WHEN CurrentSales - LAG(CurrentSales) OVER(PARTITION BY Product ORDER BY `Year`) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS PyChange
FROM(
    SELECT
        YEAR(s.InvoiceDate) AS `Year`,
        p.Product,
        ROUND(SUM(s.TotalAmount)) AS CurrentSales
    FROM fact_sales s
    JOIN dim_products p USING(ProductID)
    GROUP BY YEAR(s.InvoiceDate), p.Product
)t;
