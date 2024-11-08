INSERT INTO hydro_admin.CUSTOMERS VALUES (1, 'John', 'Doe', 'john.doe@email.com', '555-0101', '123 Main St');
INSERT INTO hydro_admin.CUSTOMERS VALUES (2, 'Jane', 'Smith', 'jane.smith@email.com', '555-0102', '456 Oak St');
INSERT INTO hydro_admin.CUSTOMERS VALUES (3, 'Alice', 'Johnson', 'alice.johnson@email.com', '555-0103', '789 Maple St');
INSERT INTO hydro_admin.CUSTOMERS VALUES (4, 'Bob', 'Williams', 'bob.williams@email.com', '555-0104', '101 Pine St');
INSERT INTO hydro_admin.CUSTOMERS VALUES (5, 'Chris', 'Brown', 'chris.brown@email.com', '555-0105', '202 Elm St');
INSERT INTO hydro_admin.CUSTOMERS VALUES (6, 'David', 'Clark', 'david.clark@email.com', '555-0106', '303 Oak St');

INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(1, 1, DATE '2024-03-01', 299.50);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(2, 2, DATE '2024-03-02', 199.75);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(3, 3, DATE '2024-03-03', 449.25);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(4, 4, DATE '2024-03-04', 159.99);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(5, 5, DATE '2024-03-05', 399.99);



INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(1, 1, 1, 20.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(2, 2, 2, 15.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(3, 3, 3, 20.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(4, 4, 4, 20.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(5, 5, 5, 10.00);


-- Insert multiple orders
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES (6, 1, DATE '2024-03-06', 150.75);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES (7, 2, DATE '2024-03-07', 275.50);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES (8, 3, DATE '2024-04-01', 325.90);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES (9, 4, DATE '2024-04-02', 200.80);
INSERT INTO hydro_admin.ORDERS (order_id, customer_id, order_date, total_amount) VALUES (10, 5, DATE '2024-04-03', 180.45);

-- Add order items for each order
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (6, 6, 1, 15.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (7, 6, 2, 10.00);

INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (8, 7, 3, 12.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (9, 7, 4, 20.00);

INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (10, 8, 5, 18.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (11, 8, 1, 22.00);

INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (12, 9, 2, 25.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (13, 9, 3, 30.00);

INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (14, 10, 4, 15.00);
INSERT INTO hydro_admin.ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES (15, 10, 5, 10.00);

UPDATE hydro_admin.HARVESTED_CROPS SET order_item_id = 1 WHERE harvest_id = 1;
UPDATE hydro_admin.HARVESTED_CROPS SET order_item_id = 2 WHERE harvest_id = 2;
UPDATE hydro_admin.HARVESTED_CROPS SET order_item_id = 3 WHERE harvest_id = 3;
UPDATE hydro_admin.HARVESTED_CROPS SET order_item_id = 4 WHERE harvest_id = 4;
UPDATE hydro_admin.HARVESTED_CROPS SET order_item_id = 5 WHERE harvest_id = 5;


