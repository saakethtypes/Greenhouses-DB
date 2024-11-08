INSERT INTO hydro_admin.CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(1, 'Tomatoes', 'Temperature: 20-25°C, Humidity: 60-80%', 90, 5.99);
INSERT INTO hydro_admin.CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(2, 'Lettuce', 'Temperature: 15-20°C, Humidity: 50-70%', 45, 3.99);
INSERT INTO hydro_admin.CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(3, 'Cucumbers', 'Temperature: 22-28°C, Humidity: 70-90%', 60, 4.99);
INSERT INTO hydro_admin.CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(4, 'Bell Peppers', 'Temperature: 18-23°C, Humidity: 60-70%', 75, 6.99);
INSERT INTO hydro_admin.CROP_TYPES (crop_type_id, crop_name, growing_conditions, harvest_time_days, price_per_100g) VALUES
(5, 'Herbs', 'Temperature: 18-22°C, Humidity: 40-60%', 30, 8.99);

INSERT INTO hydro_admin.GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(1, 1, NULL, 'Seedling', DATE '2024-01-01', DATE '2024-04-01');
INSERT INTO hydro_admin.GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(2, 2, NULL, 'Vegetative', DATE '2024-01-15', DATE '2024-03-01');
INSERT INTO hydro_admin.GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(3, 3, NULL, 'Flowering', DATE '2024-02-01', DATE '2024-04-01');
INSERT INTO hydro_admin.GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(4, 4, NULL, 'Harvest', DATE '2024-01-01', DATE '2024-03-15');
INSERT INTO hydro_admin.GROWTH_CYCLE (growth_cycle_id, crop_type_id, plant_bed_id, stage, start_date, end_date) VALUES
(5, 5, NULL, 'Seedling', DATE '2024-02-15', DATE '2024-03-15');


-- PLANT_BEDS table inserts (ensuring unique crop per bed per cycle)
INSERT INTO hydro_admin.PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(1, 'A1', 50, 1, 1, 1, 45);
INSERT INTO hydro_admin.PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(2, 'B1', 40, 1, 2, 2, 35);
INSERT INTO hydro_admin.PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(3, 'C1', 45, 2, 3, 3, 40);
INSERT INTO hydro_admin.PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(4, 'D1', 55, 2, 4, 4, 50);
INSERT INTO hydro_admin.PLANT_BEDS (plant_bed_id, slot_code, capacity, greenhouse_id, crop_type_id, growth_cycle_id, planted_quantity) VALUES
(5, 'E1', 35, 3, 5, 5, 30);


-- Update GROWTH_CYCLE with plant_bed_ids
UPDATE hydro_admin.GROWTH_CYCLE SET plant_bed_id = 1 WHERE growth_cycle_id = 1;
UPDATE hydro_admin.GROWTH_CYCLE SET plant_bed_id = 2 WHERE growth_cycle_id = 2;
UPDATE hydro_admin.GROWTH_CYCLE SET plant_bed_id = 3 WHERE growth_cycle_id = 3;
UPDATE hydro_admin.GROWTH_CYCLE SET plant_bed_id = 4 WHERE growth_cycle_id = 4;
UPDATE hydro_admin.GROWTH_CYCLE SET plant_bed_id = 5 WHERE growth_cycle_id = 5;

INSERT INTO hydro_admin.HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(1, 1, DATE '2024-03-01', 100.00, 80.00, 1, NULL);
INSERT INTO hydro_admin.HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(2, 2, DATE '2024-03-02', 75.00, 60.00, 2, NULL);
INSERT INTO hydro_admin.HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(3, 3, DATE '2024-03-03', 90.00, 70.00, 3, NULL);
INSERT INTO hydro_admin.HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(4, 4, DATE '2024-03-04', 85.00, 65.00, 4, NULL);
INSERT INTO hydro_admin.HARVESTED_CROPS (harvest_id, crop_type_id, harvest_date, quantity_kg, available_quantity_kg, growth_cycle_id, order_item_id) VALUES
(5, 5, DATE '2024-03-05', 50.00, 40.00, 5, NULL);


-- Update planted quantities in plant beds
UPDATE hydro_admin.PLANT_BEDS SET planted_quantity = 25 WHERE plant_bed_id = 1;
UPDATE hydro_admin.PLANT_BEDS SET planted_quantity = 30 WHERE plant_bed_id = 2;
UPDATE hydro_admin.PLANT_BEDS SET planted_quantity = 35 WHERE plant_bed_id = 3;
UPDATE hydro_admin.PLANT_BEDS SET planted_quantity = 40 WHERE plant_bed_id = 4;
UPDATE hydro_admin.PLANT_BEDS SET planted_quantity = 20 WHERE plant_bed_id = 5;

