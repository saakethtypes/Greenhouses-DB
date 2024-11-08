INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(1, 1, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(2, 2, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(3, 3, 'Temperature', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(4, 4, 'Humidity', DATE '2024-01-01');
INSERT INTO hydro_admin.SENSORS (sensor_id, plant_bed_id, sensor_type, installation_date) VALUES
(5, 5, 'Humidity', DATE '2024-01-01');


-- SENSOR_LOGS table inserts (ensuring unique timestamp per sensor)
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(1, 1, TIMESTAMP '2024-03-01 08:00:00', 22.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(2, 1, TIMESTAMP '2024-03-01 09:00:00', 23.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(3, 2, TIMESTAMP '2024-03-01 08:00:00', 65.0);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(4, 3, TIMESTAMP '2024-03-01 08:00:00', 66.5);
INSERT INTO hydro_admin.SENSOR_LOGS (log_id, sensor_id, timestamp, reading_value) VALUES
(5, 4, TIMESTAMP '2024-03-01 08:00:00', 21.5);
