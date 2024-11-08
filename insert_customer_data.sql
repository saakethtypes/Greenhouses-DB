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
