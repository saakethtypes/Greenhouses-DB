-- Main setup script
SET SERVEROUTPUT ON;
WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Clean up existing objects
BEGIN
    -- Drop tables in correct order to handle dependencies
    FOR t IN (SELECT table_name 
              FROM user_tables 
              WHERE table_name IN ('ORDER_ITEMS', 'SENSOR_LOGS', 'SENSORS', 'ORDERS', 
                                 'HARVESTED_CROPS', 'GROWTH_CYCLE', 'PLANT_BEDS', 
                                 'CROP_TYPES', 'GREENHOUSES', 'CUSTOMERS')) 
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
                RAISE;
            END IF;
    END LOOP;
END;
/

-- Create tables
CREATE TABLE CUSTOMERS (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    email VARCHAR2(50),
    phone VARCHAR2(50),
    address VARCHAR2(200)
);

CREATE TABLE GREENHOUSES (
    greenhouse_id NUMBER PRIMARY KEY,
    location VARCHAR2(100),
    total_slots NUMBER
);

CREATE TABLE CROP_TYPES (
    crop_type_id NUMBER PRIMARY KEY,
    crop_name VARCHAR2(50),
    growing_conditions VARCHAR2(200),
    harvest_time_days NUMBER,
    price_per_100g DECIMAL(10, 2)
);

CREATE TABLE PLANT_BEDS (
    plant_bed_id NUMBER PRIMARY KEY,
    slot_code VARCHAR2(20),
    capacity NUMBER,
    greenhouse_id NUMBER REFERENCES GREENHOUSES(greenhouse_id),
    crop_type_id NUMBER REFERENCES CROP_TYPES(crop_type_id),
    growth_cycle_id NUMBER
);

CREATE TABLE GROWTH_CYCLE (
    growth_cycle_id NUMBER PRIMARY KEY,
    crop_type_id NUMBER REFERENCES CROP_TYPES(crop_type_id),
    plant_bed_id NUMBER,
    stage VARCHAR2(50),
    start_date DATE,
    end_date DATE
);

-- Add foreign key after both tables exist
ALTER TABLE PLANT_BEDS ADD CONSTRAINT fk_growth_cycle 
    FOREIGN KEY (growth_cycle_id) REFERENCES GROWTH_CYCLE(growth_cycle_id);

CREATE TABLE ORDERS (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER REFERENCES CUSTOMERS(customer_id),
    order_date DATE,
    total_amount DECIMAL(10, 2)
);

CREATE TABLE HARVESTED_CROPS (
    harvest_id NUMBER PRIMARY KEY,
    crop_type_id NUMBER REFERENCES CROP_TYPES(crop_type_id),
    harvest_date DATE,
    quantity_kg DECIMAL(10, 2),
    available_quantity_kg DECIMAL(10, 2),
    growth_cycle_id NUMBER REFERENCES GROWTH_CYCLE(growth_cycle_id),
    order_item_id NUMBER
);

CREATE TABLE SENSORS (
    sensor_id NUMBER PRIMARY KEY,
    plant_bed_id NUMBER REFERENCES PLANT_BEDS(plant_bed_id),
    sensor_type VARCHAR2(50),
    installation_date DATE
);

CREATE TABLE SENSOR_LOGS (
    log_id NUMBER PRIMARY KEY,
    sensor_id NUMBER REFERENCES SENSORS(sensor_id),
    timestamp TIMESTAMP,
    reading_value DECIMAL(10, 2)
);

CREATE TABLE ORDER_ITEMS (
    order_item_id NUMBER PRIMARY KEY,
    order_id NUMBER REFERENCES ORDERS(order_id),
    harvest_id NUMBER REFERENCES HARVESTED_CROPS(harvest_id),
    quantity_kg DECIMAL(10, 2)
);

-- Add foreign key after both tables exist
ALTER TABLE HARVESTED_CROPS ADD CONSTRAINT fk_order_item 
    FOREIGN KEY (order_item_id) REFERENCES ORDER_ITEMS(order_item_id);

-- Insert sample data
INSERT INTO CUSTOMERS VALUES (1, 'John', 'Doe', 'john@email.com', '555-0101', '123 Main St');
INSERT INTO CUSTOMERS VALUES (2, 'Jane', 'Smith', 'jane@email.com', '555-0102', '456 Oak Ave');
INSERT INTO CUSTOMERS VALUES (3, 'Bob', 'Johnson', 'bob@email.com', '555-0103', '789 Pine Rd');
INSERT INTO CUSTOMERS VALUES (4, 'Alice', 'Williams', 'alice@email.com', '555-0104', '321 Elm St');
INSERT INTO CUSTOMERS VALUES (5, 'Charlie', 'Brown', 'charlie@email.com', '555-0105', '654 Maple Dr');

INSERT INTO GREENHOUSES VALUES (1, 'North Wing', 100);
INSERT INTO GREENHOUSES VALUES (2, 'South Wing', 120);
INSERT INTO GREENHOUSES VALUES (3, 'East Wing', 80);

INSERT INTO CROP_TYPES VALUES (1, 'Tomatoes', 'Temp: 20-25C, Humidity: 60-80%', 90, 5.99);
INSERT INTO CROP_TYPES VALUES (2, 'Lettuce', 'Temp: 15-20C, Humidity: 50-70%', 45, 3.99);
INSERT INTO CROP_TYPES VALUES (3, 'Cucumbers', 'Temp: 22-28C, Humidity: 70-90%', 60, 4.99);

-- Create users and roles
CREATE ROLE admin_role;
CREATE ROLE technician_role;
CREATE ROLE agronomist_role;
CREATE ROLE sales_manager_role;
CREATE ROLE customer_role;

-- Grant privileges to roles
GRANT ALL PRIVILEGES ON CUSTOMERS TO admin_role;
GRANT ALL PRIVILEGES ON GREENHOUSES TO admin_role;
GRANT ALL PRIVILEGES ON CROP_TYPES TO admin_role;
GRANT ALL PRIVILEGES ON PLANT_BEDS TO admin_role;
GRANT ALL PRIVILEGES ON GROWTH_CYCLE TO admin_role;
GRANT ALL PRIVILEGES ON HARVESTED_CROPS TO admin_role;
GRANT ALL PRIVILEGES ON SENSORS TO admin_role;
GRANT ALL PRIVILEGES ON SENSOR_LOGS TO admin_role;
GRANT ALL PRIVILEGES ON ORDERS TO admin_role;
GRANT ALL PRIVILEGES ON ORDER_ITEMS TO admin_role;

-- Technician privileges
GRANT SELECT ON PLANT_BEDS TO technician_role;
GRANT SELECT ON CROP_TYPES TO technician_role;
GRANT SELECT ON SENSORS TO technician_role;
GRANT SELECT, INSERT, UPDATE ON SENSOR_LOGS TO technician_role;
GRANT SELECT ON GROWTH_CYCLE TO technician_role;

-- Agronomist privileges
GRANT SELECT, UPDATE ON PLANT_BEDS TO agronomist_role;
GRANT SELECT, UPDATE ON CROP_TYPES TO agronomist_role;
GRANT SELECT, UPDATE ON GROWTH_CYCLE TO agronomist_role;
GRANT SELECT ON SENSOR_LOGS TO agronomist_role;

-- Sales Manager privileges
GRANT SELECT ON HARVESTED_CROPS TO sales_manager_role;
GRANT SELECT ON ORDERS TO sales_manager_role;
GRANT SELECT ON ORDER_ITEMS TO sales_manager_role;
GRANT SELECT ON CUSTOMERS TO sales_manager_role;

-- Customer privileges
CREATE OR REPLACE VIEW customer_orders AS
SELECT o.*, oi.order_item_id, oi.quantity_kg, hc.crop_type_id
FROM ORDERS o
JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
JOIN HARVESTED_CROPS hc ON oi.harvest_id = hc.harvest_id;

GRANT SELECT ON customer_orders TO customer_role;

-- Create useful views
CREATE OR REPLACE VIEW crop_status AS
SELECT 
    ct.crop_name,
    pb.slot_code,
    gh.location as greenhouse_location,
    gc.stage,
    gc.start_date,
    gc.end_date
FROM PLANT_BEDS pb
JOIN GREENHOUSES gh ON pb.greenhouse_id = gh.greenhouse_id
JOIN CROP_TYPES ct ON pb.crop_type_id = ct.crop_type_id
JOIN GROWTH_CYCLE gc ON pb.growth_cycle_id = gc.growth_cycle_id;

CREATE OR REPLACE VIEW sensor_statistics AS
SELECT 
    s.sensor_type,
    pb.slot_code,
    gh.location as greenhouse_location,
    AVG(sl.reading_value) as avg_reading,
    MIN(sl.reading_value) as min_reading,
    MAX(sl.reading_value) as max_reading
FROM SENSOR_LOGS sl
JOIN SENSORS s ON sl.sensor_id = s.sensor_id
JOIN PLANT_BEDS pb ON s.plant_bed_id = pb.plant_bed_id
JOIN GREENHOUSES gh ON pb.greenhouse_id = gh.greenhouse_id
GROUP BY s.sensor_type, pb.slot_code, gh.location;

COMMIT;
