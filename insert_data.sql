INSERT INTO CUSTOMERS VALUES (1, 'John', 'Doe', 'john.doe@email.com', '555-0101', '123 Main St');
INSERT INTO CUSTOMERS VALUES (2, 'Jane', 'Smith', 'jane.smith@email.com', '555-0102', '456 Oak St');
INSERT INTO CUSTOMERS VALUES (3, 'Alice', 'Johnson', 'alice.johnson@email.com', '555-0103', '789 Maple St');
INSERT INTO CUSTOMERS VALUES (4, 'Bob', 'Williams', 'bob.williams@email.com', '555-0104', '101 Pine St');
INSERT INTO CUSTOMERS VALUES (5, 'Chris', 'Brown', 'chris.brown@email.com', '555-0105', '202 Elm St');
INSERT INTO CUSTOMERS VALUES (6, 'David', 'Clark', 'david.clark@email.com', '555-0106', '303 Oak St');

INSERT INTO GREENHOUSES (greenhouse_id, location, total_slots) VALUES
(1, 'North Wing', 100);
INSERT INTO GREENHOUSES (greenhouse_id, location, total_slots) VALUES
(2, 'South Wing', 150);
INSERT INTO GREENHOUSES (greenhouse_id, location, total_slots) VALUES
(3, 'East Wing', 125);
INSERT INTO GREENHOUSES (greenhouse_id, location, total_slots) VALUES
(4, 'West Wing', 175);
INSERT INTO GREENHOUSES (greenhouse_id, location, total_slots) VALUES
(5, 'Central Wing', 200);

INSERT INTO CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(1, 'Tomatoes', 'Temperature: 20-25°C, Humidity: 60-80%', 90, 5.99);
INSERT INTO CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(2, 'Lettuce', 'Temperature: 15-20°C, Humidity: 50-70%', 45, 3.99);
INSERT INTO CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(3, 'Cucumbers', 'Temperature: 22-28°C, Humidity: 70-90%', 60, 4.99);
INSERT INTO CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(4, 'Bell Peppers', 'Temperature: 18-23°C, Humidity: 60-70%', 75, 6.99);
INSERT INTO CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(5, 'Herbs', 'Temperature: 18-22°C, Humidity: 40-60%', 30, 8.99);

INSERT INTO GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(1, 1, NULL, 'Seedling', DATE '2024-01-01', DATE '2024-04-01');
INSERT INTO GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(2, 2, NULL, 'Vegetative', DATE '2024-01-15', DATE '2024-03-01');
INSERT INTO GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(3, 3, NULL, 'Flowering', DATE '2024-02-01', DATE '2024-04-01');
INSERT INTO GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(4, 4, NULL, 'Harvest', DATE '2024-01-01', DATE '2024-03-15');
INSERT INTO GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(5, 5, NULL, 'Seedling', DATE '2024-02-15', DATE '2024-03-15');


-- PLANT_BEDS table inserts (ensuring unique crop per bed per cycle)
INSERT INTO PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(1, 'A1', 50, 1, 1, 1, 45);
INSERT INTO PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(2, 'B1', 40, 1, 2, 2, 35);
INSERT INTO PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(3, 'C1', 45, 2, 3, 3, 40);
INSERT INTO PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(4, 'D1', 55, 2, 4, 4, 50);
INSERT INTO PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(5, 'E1', 35, 3, 5, 5, 30);


-- Update GROWTH_CYCLE with plant_bed_ids
UPDATE GROWTH_CYCLE SET plant_bed_id = 1 WHERE growth_cycle_id = 1;
UPDATE GROWTH_CYCLE SET plant_bed_id = 2 WHERE growth_cycle_id = 2;
UPDATE GROWTH_CYCLE SET plant_bed_id = 3 WHERE growth_cycle_id = 3;
UPDATE GROWTH_CYCLE SET plant_bed_id = 4 WHERE growth_cycle_id = 4;
UPDATE GROWTH_CYCLE SET plant_bed_id = 5 WHERE growth_cycle_id = 5;


-- ORDERS table inserts
INSERT INTO ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(1, 1, DATE '2024-03-01', 299.50);
INSERT INTO ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(2, 2, DATE '2024-03-02', 199.75);
INSERT INTO ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(3, 3, DATE '2024-03-03', 449.25);
INSERT INTO ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(4, 4, DATE '2024-03-04', 159.99);
INSERT INTO ORDERS (order_id, customer_id, order_date, total_amount) VALUES
(5, 5, DATE '2024-03-05', 399.99);

-- HARVESTED_CROPS table inserts
INSERT INTO HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(1, 1, DATE '2024-03-01', 100.00, 80.00, 1, NULL);
INSERT INTO HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(2, 2, DATE '2024-03-02', 75.00, 60.00, 2, NULL);
INSERT INTO HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(3, 3, DATE '2024-03-03', 90.00, 70.00, 3, NULL);
INSERT INTO HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(4, 4, DATE '2024-03-04', 85.00, 65.00, 4, NULL);
INSERT INTO HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(5, 5, DATE '2024-03-05', 50.00, 40.00, 5, NULL);

INSERT INTO SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(1, 1, 'Temperature', DATE '2024-01-01');
INSERT INTO SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(2, 2, 'Temperature', DATE '2024-01-01');
INSERT INTO SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(3, 3, 'Temperature', DATE '2024-01-01');
INSERT INTO SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(4, 4, 'Humidity', DATE '2024-01-01');
INSERT INTO SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(5, 5, 'Humidity', DATE '2024-01-01');


-- SENSOR_LOGS table inserts (ensuring unique timestamp per sensor)
INSERT INTO SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(1, 1, TIMESTAMP '2024-03-01 08:00:00', 22.5);
INSERT INTO SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(2, 1, TIMESTAMP '2024-03-01 09:00:00', 23.0);
INSERT INTO SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(3, 2, TIMESTAMP '2024-03-01 08:00:00', 65.0);
INSERT INTO SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(4, 3, TIMESTAMP '2024-03-01 08:00:00', 66.5);
INSERT INTO SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(5, 4, TIMESTAMP '2024-03-01 08:00:00', 21.5);

-- ORDER_ITEMS table inserts
INSERT INTO ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(1, 1, 1, 20.00);
INSERT INTO ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(2, 2, 2, 15.00);
INSERT INTO ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(3, 3, 3, 20.00);
INSERT INTO ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(4, 4, 4, 20.00);
INSERT INTO ORDER_ITEMS (order_item_id, order_id, harvest_id, quantity_kg) VALUES
(5, 5, 5, 10.00);

-- Update HARVESTED_CROPS with order_item_ids
UPDATE HARVESTED_CROPS SET order_item_id = 1 WHERE harvest_id = 1;
UPDATE HARVESTED_CROPS SET order_item_id = 2 WHERE harvest_id = 2;
UPDATE HARVESTED_CROPS SET order_item_id = 3 WHERE harvest_id = 3;
UPDATE HARVESTED_CROPS SET order_item_id = 4 WHERE harvest_id = 4;
UPDATE HARVESTED_CROPS SET order_item_id = 5 WHERE harvest_id = 5;














