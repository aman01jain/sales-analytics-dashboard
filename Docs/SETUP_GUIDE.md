# Setup Guide - Sales Analytics Dashboard

Complete step-by-step guide to set up and run this project locally.

## Prerequisites

Before you begin, ensure you have the following installed:

- **PostgreSQL 16+**: https://www.postgresql.org/download/
- **Power BI Desktop**: https://powerbi.microsoft.com/desktop/
- **Python 3.8+**: https://www.python.org/downloads/
- **Git**: https://git-scm.com/downloads

## Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/sales-analytics-dashboard.git
cd sales-analytics-dashboard
```

## Step 2: Database Setup

### Create PostgreSQL Database

```bash
# On Windows (using PowerShell or CMD)
createdb -U postgres sales_analytics

# On Mac/Linux
createdb sales_analytics
```

### Run Schema Creation Script

```bash
psql -U postgres -d sales_analytics -f sql/01_create_schema.sql
```

You should see: "Table created successfully!"

### Verify Table Creation

```bash
psql -U postgres -d sales_analytics -c "\dt"
```

You should see the `orders` table listed.

## Step 3: Import Data

### Option A: Using Python Script (Recommended)

1. Install required Python packages:
```bash
pip install pandas psycopg2-binary
```

2. Edit `sql/02_import_data.py` and update the password:
```python
DB_CONFIG = {
    'dbname': 'sales_analytics',
    'user': 'postgres',
    'password': 'YOUR_PASSWORD_HERE',  # ← Change this
    'host': 'localhost',
    'port': '5432'
}
```

3. Run the import script:
```bash
python sql/02_import_data.py
```

Expected output:
```
✓ Loaded 9994 rows
✓ Dates converted
✓ Connected to database
✓ Import complete!
✓ Total rows in database: 9994
```

### Option B: Using SQL Insert Statements

```bash
psql -U postgres -d sales_analytics -f sql/04_insert_all_data.sql
```

This will take 30-60 seconds to complete.

## Step 4: Verify Data Import

Run these verification queries:

```sql
-- Connect to database
psql -U postgres -d sales_analytics

-- Check row count
SELECT COUNT(*) FROM orders;
-- Expected: 9994

-- Check date range
SELECT MIN(order_date), MAX(order_date) FROM orders;
-- Expected: 2015-01-03 to 2018-12-30

-- Check totals
SELECT 
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM orders;
-- Expected: ~$2,297,200 sales, ~$286,400 profit
```

## Step 5: Open Power BI Dashboard

1. **Open Power BI Desktop**

2. **Open the .pbix file**:
   - File → Open
   - Navigate to `dashboard/Sales_Analytics_Dashboard.pbix`

3. **Update Data Source Connection** (if needed):
   - Click "Transform data" → "Data source settings"
   - Select PostgreSQL connection
   - Click "Change source"
   - Verify:
     - Server: `localhost`
     - Database: `sales_analytics`
   - Click OK

4. **Enter Credentials** (if prompted):
   - Select "Database" tab
   - Username: `postgres`
   - Password: [your PostgreSQL password]
   - Click Connect

5. **Refresh Data**:
   - Home tab → Refresh
   - Data should load successfully

## Step 6: Explore the Dashboard

Navigate through the 4 pages:

1. **Executive Overview**: KPIs and high-level trends
2. **Product Analysis**: Category and product performance
3. **Customer Analytics**: Customer segmentation and insights
4. **Advanced Analytics**: SQL window functions showcase

## Troubleshooting

### Issue: "Cannot connect to PostgreSQL"

**Solution**:
1. Verify PostgreSQL is running:
   ```bash
   # Windows
   Get-Service postgresql*
   
   # Mac/Linux
   pg_ctl status
   ```

2. Check if port 5432 is open:
   ```bash
   netstat -an | grep 5432
   ```

3. Verify credentials are correct

### Issue: "Table 'orders' does not exist"

**Solution**:
Run the schema creation script again:
```bash
psql -U postgres -d sales_analytics -f sql/01_create_schema.sql
```

### Issue: "Data import fails with encoding error"

**Solution**:
Use the SQL insert method (Option B) instead of CSV import:
```bash
psql -U postgres -d sales_analytics -f sql/04_insert_all_data.sql
```

### Issue: Power BI shows "Data source error"

**Solution**:
1. Install PostgreSQL ODBC driver: https://www.postgresql.org/ftp/odbc/versions/
2. Restart Power BI Desktop
3. Try connection again

### Issue: Measures show errors in Power BI

**Solution**:
1. Check that data loaded correctly (verify row count)
2. Verify measure syntax matches your Power BI version
3. Try refreshing the data model

## Testing the Dashboard

### Quick Tests

1. **Interactivity**: Click on a bar/slice in any chart → other visuals should filter
2. **Slicers**: Use any slicer to filter the page
3. **Drill-through**: Right-click on data points to explore details

### Sample Queries to Run

Try these queries in pgAdmin or command line:

```sql
-- Top 5 products by profit
SELECT product_name, SUM(profit) as total_profit
FROM orders
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 5;

-- Monthly sales trend
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales)::numeric, 2) AS monthly_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Customer segment breakdown
SELECT 
    segment,
    COUNT(DISTINCT customer_id) as customers,
    ROUND(SUM(sales)::numeric, 2) as total_sales
FROM orders
GROUP BY segment;
```

## Next Steps

Once everything is working:

1. **Customize**: Modify colors, themes, layouts in Power BI
2. **Extend**: Add new pages, visuals, or calculations
3. **Publish**: Share to Power BI Service (requires account)
4. **Document**: Take screenshots for your portfolio

## Resources

- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Power BI Documentation**: https://docs.microsoft.com/power-bi/
- **DAX Function Reference**: https://dax.guide/
- **SQL Tutorial**: https://www.postgresqltutorial.com/

## Support

If you encounter issues not covered here:

1. Check the main README.md for additional context
2. Review error messages carefully
3. Search PostgreSQL/Power BI forums
4. Open an issue on GitHub (if this is a public repo)

---

**Happy Analyzing! 📊**
