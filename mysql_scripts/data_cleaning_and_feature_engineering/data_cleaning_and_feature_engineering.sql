-- ====================================================================
-- 1. DATA EXPLORATION
-- Initial checks to understand the unique values in key categorical columns.
-- ====================================================================

SELECT DISTINCT `Description` FROM sales_cleaned;
SELECT DISTINCT Category FROM sales_cleaned;
SELECT DISTINCT ShipmentProvider FROM sales_cleaned;
SELECT DISTINCT PaymentMethod FROM sales_cleaned;
SELECT DISTINCT SalesChannel FROM sales_cleaned;
SELECT DISTINCT WarehouseLocation FROM sales_cleaned;
SELECT DISTINCT Country FROM sales_cleaned;
SELECT DISTINCT ReturnStatus FROM sales_cleaned;

-- ====================================================================
-- 2. HANDLING MISSING & INVALID DATA
-- Imputing missing values, correcting invalid numbers, and removing impossible records.
-- ====================================================================

-- 2.1. Impute Missing Warehouse Locations
-- Find rows with empty WarehouseLocation.
SELECT * FROM sales_cleaned WHERE WarehouseLocation = '';

-- Find a potential WarehouseLocation to fill in based on other orders from the same country.
SELECT s1.WarehouseLocation, s2.WarehouseLocation
FROM sales_cleaned s1
JOIN sales_cleaned s2 USING(Country)
WHERE s1.WarehouseLocation = '' AND (s2.WarehouseLocation != '' OR s2.WarehouseLocation IS NOT NULL);

-- Update empty WarehouseLocation using a value from another order in the same country.
-- Note: This assumes a country is served by a single warehouse.
UPDATE sales_cleaned s1
JOIN sales_cleaned s2 USING(Country)
SET s1.WarehouseLocation = s2.WarehouseLocation
WHERE s1.WarehouseLocation = '' AND (s2.WarehouseLocation != '');

-- 2.2. Remove Impossible Data
-- Delete records where the discount is greater than 100%, as this is invalid.
DELETE FROM sales_cleaned
WHERE Discount > 1;

-- 2.3. Correct Negative Numeric Values
-- Convert negative UnitPrice, Discount, and ShippingCost to their absolute values.
-- Note: This assumes negative values are data entry errors.
UPDATE sales_cleaned SET UnitPrice = ABS(UnitPrice) WHERE UnitPrice < 0;
UPDATE sales_cleaned SET Discount = ABS(Discount) WHERE Discount < 0;
UPDATE sales_cleaned SET ShippingCost = ABS(ShippingCost) WHERE ShippingCost < 0;

-- ====================================================================
-- 3. REMOVING DUPLICATES
-- Find and inspect exact duplicate rows across all columns.
-- ====================================================================

-- Identify duplicate rows using a window function to assign a row number to identical records.
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY InvoiceNo, StockCode, `Description`,
            Quantity, InvoiceDate, UnitPrice, CustomerID, Country, Discount, PaymentMethod, ShippingCost, Category,
            SalesChannel, ReturnStatus, ShipmentProvider, WarehouseLocation, OrderPriority
        ) AS row_num
    FROM sales_cleaned
) AS subquery
WHERE subquery.row_num > 1;

-- ====================================================================
-- 4. DATA TYPE & FORMATTING CORRECTION
-- Standardize the format of columns, particularly dates.
-- ====================================================================

-- Check the conversion from text to a proper DATE format, stripping the time part.
SELECT
    STR_TO_DATE(InvoiceDate, "%Y-%m-%d %H:%i"),
    DATE(STR_TO_DATE(InvoiceDate, "%Y-%m-%d %H:%i"))
FROM sales_cleaned;

-- Update the InvoiceDate column to the new format (YYYY-MM-DD).
UPDATE sales_cleaned
SET InvoiceDate = DATE(STR_TO_DATE(InvoiceDate, "%Y-%m-%d %H:%i"));

-- Modify the column's data type to DATE for proper storage and querying.
ALTER TABLE sales_cleaned
MODIFY COLUMN InvoiceDate DATE;

-- ====================================================================
-- 5. FEATURE ENGINEERING & DATA ENRICHMENT
-- Create new columns and standardize existing ones for better analysis.
-- ====================================================================

-- 5.1. Add TotalAmount Column
-- Add a new column to store the calculated total amount of each transaction.
ALTER TABLE sales_cleaned ADD COLUMN TotalAmount DECIMAL(5, 2);

-- Modify the precision of the new column to accommodate larger values.
ALTER TABLE sales_cleaned MODIFY COLUMN TotalAmount DECIMAL(15, 2);

-- Calculate and populate the TotalAmount for each row.
UPDATE sales_cleaned
SET TotalAmount = ROUND((Quantity * UnitPrice) - (Quantity * UnitPrice * Discount), 2);

-- 5.2. Standardize Categories
-- Inspect the relationship between Description and Category.
SELECT `Description`, Category FROM sales_cleaned;

-- Update the Category column based on keywords in the Description for consistency.
UPDATE sales_cleaned
SET Category =
    CASE
        WHEN `Description` IN ('T-shirt', 'Backpack') THEN 'Apparel'
        WHEN `Description` IN ('Wireless Mouse', 'Headphones', 'Wall Clock') THEN 'Electronics'
        WHEN `Description` IN ('USB Cable', 'White Mug') THEN 'Accessories'
        WHEN `Description` IN ('Notebook', 'Blue Pen') THEN 'Stationery'
        ELSE 'Furniture'
    END;
