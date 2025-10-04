# MySQL Scripts – Superstore Sales Analytics

This folder contains all MySQL scripts for building, cleaning, modeling, and analyzing the sales database for the Superstore Sales Analytics project.

---

## Script Guide

- **database_setup.sql**  
  Sets up the database, verifies original imported data, and creates a working copy for cleaning.

- **data_cleaning_and_feature_engineering.sql**  
  Cleans data, fixes issues, removes duplicates, formats dates, and creates analysis-ready columns.

- **star_schema_and_fact_table.sql**  
  Builds dimension tables (products, customers, shipment) and a central fact table for BI modeling.

- **analysis_and_dashboard_views.sql**  
  Defines analytical views (KPIs, customer/product analysis, shipment, and time-series trends) for dashboarding in BI tools.

---

## Usage

1. Start with `database_setup.sql`
2. Run `data_cleaning_and_feature_engineering.sql`
3. Execute `star_schema_and_fact_table.sql`
4. Finish with `analysis_and_dashboard_views.sql`

Run these scripts in order using your SQL client after loading the raw data.

---

## Author

Abdelrahman Mohamed Salem
