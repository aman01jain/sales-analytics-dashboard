"""
Import Superstore CSV data into PostgreSQL
Handles encoding issues and date formatting automatically
"""

import pandas as pd
import psycopg2
from psycopg2 import sql
from datetime import datetime

# ============================================
# CONFIGURATION - UPDATE THESE VALUES
# ============================================
DB_CONFIG = {
    'dbname': 'sales_analytics',
    'user': 'postgres',
    'password': 'YOUR_PASSWORD_HERE',  # Change this to your PostgreSQL password
    'host': 'localhost',
    'port': '5432'
}

CSV_FILE = 'Sample_-_Superstore.csv'

# ============================================
# IMPORT FUNCTION
# ============================================

def import_data():
    """Import CSV data into PostgreSQL"""
    
    print("Step 1: Reading CSV file...")
    # Read CSV with proper encoding
    df = pd.read_csv(CSV_FILE, encoding='ISO-8859-1')
    
    print(f"✓ Loaded {len(df)} rows")
    print(f"✓ Columns: {list(df.columns)}")
    
    # Clean column names (remove spaces, lowercase)
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('-', '_')
    
    print("\nStep 2: Converting date columns...")
    # Convert date columns
    df['order_date'] = pd.to_datetime(df['order_date'])
    df['ship_date'] = pd.to_datetime(df['ship_date'])
    
    print("✓ Dates converted")
    
    # Handle missing values
    df['postal_code'] = df['postal_code'].fillna('00000')
    
    print("\nStep 3: Connecting to PostgreSQL...")
    # Connect to database
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("✓ Connected to database")
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        print("\nMake sure to update the password in DB_CONFIG!")
        return
    
    print("\nStep 4: Inserting data...")
    # Insert data row by row (for safety and error handling)
    insert_query = """
        INSERT INTO orders (
            row_id, order_id, order_date, ship_date, ship_mode,
            customer_id, customer_name, segment, country, city,
            state, postal_code, region, product_id, category,
            sub_category, product_name, sales, quantity, discount, profit
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    success_count = 0
    error_count = 0
    
    for idx, row in df.iterrows():
        try:
            cursor.execute(insert_query, tuple(row))
            success_count += 1
            
            # Progress indicator
            if (idx + 1) % 1000 == 0:
                print(f"  Processed {idx + 1}/{len(df)} rows...")
                conn.commit()  # Commit every 1000 rows
                
        except Exception as e:
            error_count += 1
            if error_count <= 5:  # Only show first 5 errors
                print(f"  Error on row {idx}: {e}")
    
    # Final commit
    conn.commit()
    
    print(f"\n{'='*50}")
    print(f"✓ Import complete!")
    print(f"  Successfully inserted: {success_count} rows")
    print(f"  Errors: {error_count} rows")
    print(f"{'='*50}")
    
    # Verify data
    print("\nStep 5: Verifying data...")
    cursor.execute("SELECT COUNT(*) FROM orders")
    count = cursor.fetchone()[0]
    print(f"✓ Total rows in database: {count}")
    
    cursor.execute("SELECT MIN(order_date), MAX(order_date) FROM orders")
    min_date, max_date = cursor.fetchone()
    print(f"✓ Date range: {min_date} to {max_date}")
    
    cursor.execute("SELECT SUM(sales), SUM(profit) FROM orders")
    total_sales, total_profit = cursor.fetchone()
    print(f"✓ Total Sales: ${total_sales:,.2f}")
    print(f"✓ Total Profit: ${total_profit:,.2f}")
    
    # Close connection
    cursor.close()
    conn.close()
    print("\n✓ Database connection closed")

# ============================================
# RUN IMPORT
# ============================================

if __name__ == "__main__":
    print("\n" + "="*50)
    print("SUPERSTORE DATA IMPORT SCRIPT")
    print("="*50 + "\n")
    
    import_data()
    
    print("\nNext steps:")
    print("1. Open pgAdmin and verify the data")
    print("2. Run the sample queries in '03_sample_queries.sql'")
    print("3. Connect Power BI to PostgreSQL")
