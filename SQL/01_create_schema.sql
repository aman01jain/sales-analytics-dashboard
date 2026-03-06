-- ============================================
-- CREATE SCHEMA FOR SUPERSTORE SALES DATABASE
-- ============================================

-- Drop table if exists (for clean reinstall)
DROP TABLE IF EXISTS orders CASCADE;

-- Create orders table
CREATE TABLE orders (
    row_id INTEGER PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    order_date DATE NOT NULL,
    ship_date DATE NOT NULL,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50) NOT NULL,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(255),
    sales DECIMAL(10,4),
    quantity INTEGER,
    discount DECIMAL(5,4),
    profit DECIMAL(10,4)
);

-- Create indexes for better query performance
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_product_id ON orders(product_id);
CREATE INDEX idx_category ON orders(category);
CREATE INDEX idx_region ON orders(region);

-- Verify table was created
SELECT 'Table created successfully!' AS status;
