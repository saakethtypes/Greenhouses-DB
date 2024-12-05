---- Fixed Growth Stage Progression Trigger
--CREATE OR REPLACE TRIGGER trg_growth_stage_progress
--AFTER UPDATE ON growth_cycle
--FOR EACH ROW
--WHEN (NEW.stage != 'Harvest')
--DECLARE
--    v_harvest_time NUMBER;
--    v_days_elapsed NUMBER;
--    v_next_stage VARCHAR2(20);
--BEGIN
--    -- Get harvest time for this crop
--    SELECT harvest_time_days 
--    INTO v_harvest_time
--    FROM crop_types 
--    WHERE crop_type_id = :NEW.crop_type_id;
--    
--    v_days_elapsed := SYSDATE - :NEW.start_date;
--    
--    -- Calculate progression based on elapsed time
--    IF :NEW.stage = 'Seedling' AND v_days_elapsed >= (v_harvest_time * 0.25) THEN
--        v_next_stage := 'Vegetative';
--    ELSIF :NEW.stage = 'Vegetative' AND v_days_elapsed >= (v_harvest_time * 0.5) THEN
--        v_next_stage := 'Flowering';
--    ELSIF :NEW.stage = 'Flowering' AND v_days_elapsed >= v_harvest_time THEN
--        v_next_stage := 'Harvest';
--    END IF;
--    
--    -- Update to next stage if needed
--    IF v_next_stage IS NOT NULL THEN
--        UPDATE growth_cycle
--        SET stage = v_next_stage
--        WHERE growth_cycle_id = :NEW.growth_cycle_id;
--    END IF;
--END;

--/

SHOW ERRORS;

-- Now let's create queries to view data in all tables
CREATE OR REPLACE PACKAGE data_view_pkg IS
    PROCEDURE show_all_data;
END data_view_pkg;
/

CREATE OR REPLACE PACKAGE BODY data_view_pkg IS
    PROCEDURE show_all_data IS
    BEGIN
        -- View Greenhouses
        DBMS_OUTPUT.PUT_LINE('=== GREENHOUSES ===');
        FOR r IN (
            SELECT greenhouse_id, location, total_slots 
            FROM greenhouses 
            ORDER BY greenhouse_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || r.greenhouse_id || 
                ', Location: ' || r.location || 
                ', Slots: ' || r.total_slots
            );
        END LOOP;

        -- View Crop Types
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== CROP TYPES ===');
        FOR r IN (
            SELECT crop_type_id, crop_name, harvest_time_days, price_per_100g 
            FROM crop_types 
            ORDER BY crop_type_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || r.crop_type_id || 
                ', Name: ' || r.crop_name || 
                ', Days: ' || r.harvest_time_days ||
                ', Price: $' || r.price_per_100g
            );
        END LOOP;

        -- View Plant Beds
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== PLANT BEDS ===');
        FOR r IN (
            SELECT 
                pb.plant_bed_id,
                pb.slot_code,
                g.location,
                ct.crop_name,
                pb.planted_quantity
            FROM plant_beds pb
            JOIN greenhouses g ON pb.greenhouse_id = g.greenhouse_id
            LEFT JOIN crop_types ct ON pb.crop_type_id = ct.crop_type_id
            ORDER BY pb.plant_bed_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || r.plant_bed_id || 
                ', Slot: ' || r.slot_code ||
                ', Location: ' || r.location ||
                ', Crop: ' || NVL(r.crop_name, 'Empty') ||
                ', Quantity: ' || NVL(TO_CHAR(r.planted_quantity), '0')
            );
        END LOOP;

        -- View Growth Cycles
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== GROWTH CYCLES ===');
        FOR r IN (
            SELECT 
                gc.growth_cycle_id,
                ct.crop_name,
                gc.stage,
                gc.start_date,
                gc.end_date
            FROM growth_cycle gc
            JOIN crop_types ct ON gc.crop_type_id = ct.crop_type_id
            ORDER BY gc.growth_cycle_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || r.growth_cycle_id || 
                ', Crop: ' || r.crop_name ||
                ', Stage: ' || r.stage ||
                ', Started: ' || TO_CHAR(r.start_date, 'DD-MON-YY')
            );
        END LOOP;

        -- View Sensors
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== SENSORS ===');
        FOR r IN (
            SELECT 
                s.sensor_id,
                s.sensor_type,
                pb.slot_code,
                g.location
            FROM sensors s
            JOIN plant_beds pb ON s.plant_bed_id = pb.plant_bed_id
            JOIN greenhouses g ON pb.greenhouse_id = g.greenhouse_id
            ORDER BY s.sensor_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || r.sensor_id || 
                ', Type: ' || r.sensor_type ||
                ', Location: ' || r.location ||
                ', Bed: ' || r.slot_code
            );
        END LOOP;

--        -- View Recent Sensor Logs (last 24 hours)
--        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== RECENT SENSOR LOGS ===');
--        FOR r IN (
--            SELECT 
--                sl.sensor_id,
--                s.sensor_type,
--                sl.timestamp,
--                sl.reading_value
--            FROM sensor_logs sl
--            JOIN sensors s ON sl.sensor_id = s.sensor_id
--            WHERE sl.timestamp >= SYSDATE - 1
--            ORDER BY sl.timestamp DESC
--        ) LOOP
--            DBMS_OUTPUT.PUT_LINE(
--                'Sensor: ' || r.sensor_id || 
--                ', Type: ' || r.sensor_type ||
--                ', Time: ' || TO_CHAR(r.timestamp, 'DD-MON-YY HH24:MI') ||
--                ', Value: ' || r.reading_value
--            );
--        END LOOP;

        -- View Harvested Crops
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== HARVESTED CROPS ===');
        FOR r IN (
            SELECT 
                hc.harvest_id,
                ct.crop_name,
                hc.harvest_date,
                hc.quantity_kg,
                hc.available_quantity_kg
            FROM harvested_crops hc
            JOIN crop_types ct ON hc.crop_type_id = ct.crop_type_id
            ORDER BY hc.harvest_date DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || r.harvest_id || 
                ', Crop: ' || r.crop_name ||
                ', Date: ' || TO_CHAR(r.harvest_date, 'DD-MON-YY') ||
                ', Qty: ' || r.quantity_kg || 'kg' ||
                ', Available: ' || r.available_quantity_kg || 'kg'
            );
        END LOOP;

        -- View Recent Orders
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '=== RECENT ORDERS ===');
        FOR r IN (
            SELECT 
                o.order_id,
                c.first_name || ' ' || c.last_name as customer_name,
                o.order_date,
                o.total_amount
            FROM orders o
            JOIN customers c ON o.customer_id = c.customer_id
            WHERE o.order_date >= SYSDATE - 7
            ORDER BY o.order_date DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Order #' || r.order_id ||
                ' by ' || r.customer_name ||
                ' on ' || TO_CHAR(r.order_date, 'DD-MON-YY') ||
                ', Amount: $' || r.total_amount
            );
        END LOOP;
    END show_all_data;
END data_view_pkg;
/

-- Grant execute permissions
GRANT EXECUTE ON data_view_pkg TO agronomist_role, sales_manager_role, technician_role;

-- To use it:
EXEC data_view_pkg.show_all_data;
