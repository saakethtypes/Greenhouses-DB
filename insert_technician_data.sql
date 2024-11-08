-- Inserting Temperature and Humidity Sensors for Each Plant Bed
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (1, 1, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (2, 1, 'Humidity', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (3, 2, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (4, 2, 'Humidity', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (5, 3, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (6, 3, 'Humidity', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (7, 4, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (8, 4, 'Humidity', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (9, 5, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES (10, 5, 'Humidity', DATE '2024-01-01');



-- Sensor Logs for Plant Bed 1, Temperature Sensor
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (1, 1, TIMESTAMP '2024-03-01 08:00:00', 22.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (2, 1, TIMESTAMP '2024-03-01 09:00:00', 23.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (3, 1, TIMESTAMP '2024-03-01 10:00:00', 23.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (4, 1, TIMESTAMP '2024-03-01 11:00:00', 22.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (5, 1, TIMESTAMP '2024-03-01 12:00:00', 21.8);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (6, 1, TIMESTAMP '2024-03-01 13:00:00', 22.3);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (7, 1, TIMESTAMP '2024-03-01 14:00:00', 23.1);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (8, 1, TIMESTAMP '2024-03-01 15:00:00', 23.6);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (9, 1, TIMESTAMP '2024-03-01 16:00:00', 22.7);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (10, 1, TIMESTAMP '2024-03-01 17:00:00', 22.9);

-- Sensor Logs for Plant Bed 1, Humidity Sensor
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (11, 2, TIMESTAMP '2024-03-01 08:00:00', 65.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (12, 2, TIMESTAMP '2024-03-01 09:00:00', 66.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (13, 2, TIMESTAMP '2024-03-01 10:00:00', 65.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (14, 2, TIMESTAMP '2024-03-01 11:00:00', 64.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (15, 2, TIMESTAMP '2024-03-01 12:00:00', 64.8);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (16, 2, TIMESTAMP '2024-03-01 13:00:00', 65.2);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (17, 2, TIMESTAMP '2024-03-01 14:00:00', 65.8);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (18, 2, TIMESTAMP '2024-03-01 15:00:00', 66.3);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (19, 2, TIMESTAMP '2024-03-01 16:00:00', 65.7);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (20, 2, TIMESTAMP '2024-03-01 17:00:00', 65.9);



-- Plant Bed 2 (sensor_id = 4)
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (23, 4, TIMESTAMP '2024-03-01 16:00:00', 72.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (24, 4, TIMESTAMP '2024-03-01 17:00:00', 72.8);

-- Plant Bed 3 (sensor_id = 5)
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (25, 5, TIMESTAMP '2024-03-01 16:00:00', 68.4);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (26, 5, TIMESTAMP '2024-03-01 17:00:00', 68.7);

-- Plant Bed 4 (sensor_id = 6)
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (27, 6, TIMESTAMP '2024-03-01 16:00:00', 69.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES (28, 6, TIMESTAMP '2024-03-01 17:00:00', 69.2);
