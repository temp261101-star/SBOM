-- Stored Procedures for E-Commerce Platform

USE ecommerce;

DELIMITER $$

-- 1. Place a new order
CREATE PROCEDURE PlaceOrder(
    IN  p_customer_id INT,
    IN  p_product_id  INT,
    IN  p_quantity    INT,
    OUT p_order_id    INT
)
BEGIN
    DECLARE v_price    DECIMAL(10,2);
    DECLARE v_stock    INT;
    DECLARE v_total    DECIMAL(10,2);

    SELECT price, stock INTO v_price, v_stock
    FROM products WHERE product_id = p_product_id;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    SET v_total = v_price * p_quantity;

    INSERT INTO orders (customer_id, total_amount, status)
    VALUES (p_customer_id, v_total, 'Pending');

    SET p_order_id = LAST_INSERT_ID();

    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (p_order_id, p_product_id, p_quantity, v_price);

    UPDATE products SET stock = stock - p_quantity
    WHERE product_id = p_product_id;
END$$

-- 2. Update order status
CREATE PROCEDURE UpdateOrderStatus(
    IN p_order_id INT,
    IN p_status   VARCHAR(20)
)
BEGIN
    UPDATE orders SET status = p_status WHERE order_id = p_order_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

DELIMITER ;
