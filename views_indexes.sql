-- Views and Indexes for E-Commerce Platform

USE ecommerce;

-- Indexes for performance
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_products_category ON products(category);

-- View: Full order summary
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    o.total_amount,
    o.status,
    COUNT(oi.item_id) AS item_count
FROM orders o
JOIN customers  c  ON o.customer_id   = c.customer_id
JOIN order_items oi ON o.order_id     = oi.order_id
GROUP BY o.order_id, o.order_date, customer_name, c.email, o.total_amount, o.status;

-- View: Product performance
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.name,
    p.category,
    p.price,
    p.stock,
    COALESCE(SUM(oi.quantity), 0)              AS units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category, p.price, p.stock;

-- View: Customer lifetime value
CREATE OR REPLACE VIEW vw_customer_ltv AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(o.order_id)        AS total_orders,
    SUM(o.total_amount)      AS lifetime_value,
    MAX(o.order_date)        AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name, c.email;
