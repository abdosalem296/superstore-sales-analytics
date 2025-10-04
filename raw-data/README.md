# Raw Data – Superstore Sales Analytics

This folder contains the original, unprocessed dataset used to build and analyze the superstore sales data warehouse and dashboard.  
Always use this data as the source for loading into your database and for any cleaning/ETL steps.

---

## Data Description

Each row in the raw data file represents a single sales transaction.

### Common Columns (example: superstore_sales.csv)

- **InvoiceNo**: Unique identifier for each order/transaction.
- **StockCode**: Item/product code for each transaction line.
- **Description**: Product/item name.
- **Quantity**: Number of units purchased.
- **InvoiceDate**: Date (and possibly time) of transaction.
- **UnitPrice**: Price per unit at time of sale.
- **CustomerID**: Unique customer identifier.
- **Country**: Customer shipping/delivery country.
- **Discount**: Applied discount (as a fraction, e.g., 0.1 for 10%).
- **PaymentMethod**: How the transaction was paid for.
- **ShippingCost**: Delivery/shipping cost for the order.
- **Category**: Product category/segment.
- **SalesChannel**: Online/Offline/Other sales path.
- **ReturnStatus**: Whether item/order was returned or not.
- **ShipmentProvider**: Company handling delivery/shipment.
- **WarehouseLocation**: Warehouse from which the order was fulfilled.
- **OrderPriority**: Order urgency or priority indicator.

_Columns may vary slightly depending on your actual data export._

---

## Usage Notes

- Start all ETL and modeling steps with this file.
- Do not edit or overwrite the raw data; instead, use a working copy for cleaning.
- If sharing publicly, remove or anonymize any sensitive information.

---

## File Format

Standard: `.csv` (comma-separated values), loaded via MySQL, Python (pandas), Excel, or Power BI.

---

For more column details see your notebook, SQL scripts, or project documentation.
