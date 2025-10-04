-- ====================================================================
-- 1. CREATE DIMENSION TABLE: dim_products
-- Creates a table of unique products with a unique surrogate key (ProductID).
-- ====================================================================

-- Ensure a clean start by dropping the table if it already exists.
DROP TABLE IF EXISTS dim_products;

-- Create and populate the dim_products table in a single step.
CREATE TABLE IF NOT EXISTS dim_products AS
SELECT
    -- Generate a unique, sequential ID for each unique product.
    ROW_NUMBER() OVER(ORDER BY Category, Product) AS ProductID,
    Category,
    Product
FROM (
    -- Subquery to find all distinct combinations of Category and Product.
    SELECT DISTINCT
        Category,
        `Description` AS Product
    FROM sales_cleaned
) AS distinct_products;

-- Add a primary key constraint to the ProductID column for data integrity and faster joins.
ALTER TABLE dim_products
ADD PRIMARY KEY (ProductID);

-- ====================================================================
-- 2. CREATE DIMENSION TABLE: dim_customers
-- Creates a table of unique customers with a unique surrogate key (CustomerID).
-- ====================================================================

-- Ensure a clean start by dropping the table if it already exists.
DROP TABLE IF EXISTS dim_customers;

-- Create and populate the dim_customers table in a single step.
CREATE TABLE IF NOT EXISTS dim_customers AS
SELECT
    -- Generate a unique, sequential ID for each unique customer.
    ROW_NUMBER() OVER(ORDER BY CustomerID, Country) AS CustomerID,
    -- Keep the original ID as a business key for joining.
    CustomerID AS CustomerKey,
    Country
FROM (
    -- Subquery to find all distinct customer records.
    SELECT DISTINCT
        CustomerID,
        Country
    FROM sales_cleaned
) AS distinct_customers;

-- Add a primary key constraint to the new CustomerID column.
ALTER TABLE dim_customers
ADD PRIMARY KEY (CustomerID);

-- ====================================================================
-- 3. CREATE DIMENSION TABLE: dim_shipment
-- Creates a table of unique shipping attributes with a unique surrogate key (ShipmentID).
-- ====================================================================

-- Ensure a clean start by dropping the table if it already exists.
DROP TABLE IF EXISTS dim_shipment;

-- Create and populate the dim_shipment table in a single step.
CREATE TABLE IF NOT EXISTS dim_shipment AS
SELECT
    -- Generate a unique, sequential ID for each unique combination of shipping details.
    ROW_NUMBER() OVER(ORDER BY PaymentMethod, SalesChannel, ReturnStatus, ShipmentProvider, WarehouseLocation, OrderPriority) AS ShipmentID,
    PaymentMethod,
    SalesChannel,
    ReturnStatus,
    ShipmentProvider,
    WarehouseLocation,
    OrderPriority
FROM (
    -- Subquery to find all distinct combinations of shipping attributes.
    SELECT DISTINCT
        PaymentMethod,
        SalesChannel,
        ReturnStatus,
        ShipmentProvider,
        WarehouseLocation,
        OrderPriority
    FROM sales_cleaned
) AS distinct_shipment;

-- Add a primary key constraint to the ShipmentID column.
ALTER TABLE dim_shipment
ADD PRIMARY KEY (ShipmentID);

-- ====================================================================
-- 4. CREATE FACT TABLE: fact_sales
-- Creates the central fact table by joining the source data with the new dimension tables.
-- ====================================================================

-- Ensure a clean start by dropping the table if it already exists.
DROP TABLE IF EXISTS fact_sales;

-- Create and populate the fact_sales table.
CREATE TABLE IF NOT EXISTS fact_sales AS
SELECT
    -- Select transactional measures from the source table.
    s.InvoiceNo,
    s.StockCode,
    s.Quantity,
    s.InvoiceDate,
    s.UnitPrice,
    s.Discount,
    s.ShippingCost,
    s.TotalAmount,
    -- Select the foreign keys from the dimension tables.
    p.ProductID,
    c.CustomerID,
    sh.ShipmentID
FROM
    sales_cleaned s
-- Join with dim_products to get the correct ProductID foreign key.
JOIN dim_products p ON s.Description = p.Product
-- Join with dim_customers to get the correct CustomerID foreign key.
JOIN dim_customers c ON s.CustomerID = c.CustomerKey
-- Join with dim_shipment to get the correct ShipmentID foreign key.
-- Note: This join should include all columns that define the uniqueness of dim_shipment.
JOIN dim_shipment sh ON s.WarehouseLocation = sh.WarehouseLocation
                    AND s.PaymentMethod = sh.PaymentMethod
                    AND s.SalesChannel = sh.SalesChannel
                    AND s.ReturnStatus = sh.ReturnStatus
                    AND s.OrderPriority = sh.OrderPriority;
