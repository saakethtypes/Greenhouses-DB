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

    ALTER TABLE CUSTOMERS 
ADD CONSTRAINT unique_customer_email 
    UNIQUE (email);

ALTER TABLE PLANT_BEDS 
ADD CONSTRAINT unique_crop_per_bed_per_cycle 
    UNIQUE (plant_bed_id, growth_cycle_id);

ALTER TABLE SENSORS 
ADD CONSTRAINT unique_sensor_per_bed 
    UNIQUE (plant_bed_id, sensor_type);

ALTER TABLE SENSOR_LOGS 
ADD CONSTRAINT unique_timestamp_per_sensor 
    UNIQUE (sensor_id, timestamp);
-- Check Constraints
ALTER TABLE PLANT_BEDS 
ADD CONSTRAINT chk_capacity 
    CHECK (planted_quantity <= capacity);

ALTER TABLE HARVESTED_CROPS 
ADD CONSTRAINT chk_minimum_harvest_quantity 
    CHECK (quantity_kg > 0);

ALTER TABLE HARVESTED_CROPS 
ADD CONSTRAINT chk_available_quantity 
    CHECK (available_quantity_kg <= quantity_kg);

ALTER TABLE ORDER_ITEMS 
ADD CONSTRAINT chk_order_item_quantity 
    CHECK (quantity_kg > 0);

ALTER TABLE GROWTH_CYCLE 
ADD CONSTRAINT chk_growth_cycle_stage 
    CHECK (stage IN ('Seedling', 'Vegetative', 'Flowering', 'Harvest'));


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



