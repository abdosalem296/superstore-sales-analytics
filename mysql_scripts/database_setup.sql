-- ====================================================================
-- 1. DATABASE SETUP
-- Creates and selects the database for the project.
-- ====================================================================

-- Create the database named 'online_sales', but only if it doesn't already exist.
CREATE DATABASE IF NOT EXISTS online_sales;

-- Set the newly created database as the active one for all subsequent commands.
USE online_sales;

-- ====================================================================
-- 2. INITIAL DATA VERIFICATION
-- A quick check to ensure the original data has been imported correctly.
-- ====================================================================

-- Preview the first few rows of the original 'sales' table to confirm successful import.
SELECT * FROM sales;

-- ====================================================================
-- 3. CREATE A WORKING COPY OF THE DATA
-- Duplicates the original data into a new table for cleaning.
-- This is a critical best practice to preserve the raw data.
-- ====================================================================

-- Ensure a clean start by dropping any old version of the 'sales_cleaned' table.
DROP TABLE IF EXISTS sales_cleaned;

-- Create a new table named 'sales_cleaned' as a complete copy of the original 'sales' table.
-- All data cleaning operations will be performed on this new table, leaving the original data untouched.
CREATE TABLE IF NOT EXISTS sales_cleaned AS
	SELECT * FROM sales;
