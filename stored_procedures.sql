-- =============================================
-- Sequences
-- =============================================
CREATE SEQUENCE hydro_admin.customers_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE hydro_admin.greenhouse_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE hydro_admin.plant_bed_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE hydro_admin.crop_type_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE hydro_admin.growth_cycle_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE order_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE order_item_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE harvest_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE sensor_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE sensor_log_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;


-- =============================================
-- Crop Management Package
-- =============================================
CREATE OR REPLACE PACKAGE hydro_admin.crop_mgmt_pkg IS
    -- Type definitions
    TYPE crop_details_rec IS RECORD (
        crop_type_id NUMBER,
        crop_name VARCHAR2(50),
        growing_conditions VARCHAR2(200),
        harvest_time_days NUMBER,
        price_per_100g DECIMAL(10,2)
    );
    
    -- Crop type management
    PROCEDURE insert_crop_type(
        p_crop_name IN VARCHAR2,
        p_growing_conditions IN VARCHAR2,
        p_harvest_time_days IN NUMBER,
        p_price_per_100g IN DECIMAL,
        p_crop_type_id OUT NUMBER
    );
    
    -- Growth cycle management
    PROCEDURE insert_growth_cycle(
        p_crop_type_id IN NUMBER,
        p_plant_bed_id IN NUMBER,
        p_stage IN VARCHAR2,
        p_start_date IN DATE DEFAULT SYSDATE,
        p_end_date IN DATE,
        p_growth_cycle_id OUT NUMBER
    );
    
    -- Utility functions
    FUNCTION get_crop_details(
        p_crop_type_id IN NUMBER
    ) RETURN crop_details_rec;
END crop_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY hydro_admin.crop_mgmt_pkg IS
    PROCEDURE insert_crop_type(
        p_crop_name IN VARCHAR2,
        p_growing_conditions IN VARCHAR2,
        p_harvest_time_days IN NUMBER,
        p_price_per_100g IN DECIMAL,
        p_crop_type_id OUT NUMBER
    ) IS
    BEGIN
        -- Comprehensive validation
        IF p_crop_name IS NULL OR p_harvest_time_days <= 0 OR p_price_per_100g <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid crop parameters');
        END IF;

        SELECT CROP_TYPE_SEQ.NEXTVAL INTO p_crop_type_id FROM DUAL;
        
        INSERT INTO hydro_admin.CROP_TYPES (
            CROP_TYPE_ID,
            CROP_NAME,
            GROWING_CONDITIONS,
            HARVEST_TIME_DAYS,
            PRICE_PER_100G
        ) VALUES (
            p_crop_type_id,
            TRIM(p_crop_name),
            p_growing_conditions,
            p_harvest_time_days,
            p_price_per_100g
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error inserting crop type: ' || SQLERRM);
    END insert_crop_type;

    PROCEDURE insert_growth_cycle(
        p_crop_type_id IN NUMBER,
        p_plant_bed_id IN NUMBER,
        p_stage IN VARCHAR2,
        p_start_date IN DATE DEFAULT SYSDATE,
        p_end_date IN DATE,
        p_growth_cycle_id OUT NUMBER
    ) IS
        v_valid_stages CONSTANT VARCHAR2(100) := 'Seedling,Vegetative,Flowering,Harvest';
    BEGIN
        -- Validate stage
        IF INSTR(v_valid_stages, p_stage) = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid growth stage');
        END IF;

        -- Validate dates
        IF p_end_date <= p_start_date THEN
            RAISE_APPLICATION_ERROR(-20004, 'End date must be after start date');
        END IF;

        SELECT GROWTH_CYCLE_SEQ.NEXTVAL INTO p_growth_cycle_id FROM DUAL;
        
        INSERT INTO hydro_admin.GROWTH_CYCLE (
            GROWTH_CYCLE_ID,
            CROP_TYPE_ID,
            PLANT_BED_ID,
            STAGE,
            START_DATE,
            END_DATE
        ) VALUES (
            p_growth_cycle_id,
            p_crop_type_id,
            p_plant_bed_id,
            p_stage,
            p_start_date,
            p_end_date
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Error inserting growth cycle: ' || SQLERRM);
    END insert_growth_cycle;

    FUNCTION get_crop_details(
        p_crop_type_id IN NUMBER
    ) RETURN crop_details_rec IS
        v_result crop_details_rec;
    BEGIN
        SELECT crop_type_id, crop_name, growing_conditions, 
               harvest_time_days, price_per_100g
        INTO v_result
        FROM hydro_admin.CROP_TYPES
        WHERE crop_type_id = p_crop_type_id;
        
        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20006, 'Crop type not found');
    END get_crop_details;
END crop_mgmt_pkg;
/

-- =============================================
-- Customer Management Package
-- =============================================
CREATE OR REPLACE PACKAGE hydro_admin.customer_mgmt_pkg IS
    -- Customer registration
    PROCEDURE register_customer(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2
    );
    
   
END customer_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY hydro_admin.customer_mgmt_pkg IS
    PROCEDURE register_customer(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_address IN VARCHAR2
    ) IS
    BEGIN
        -- Input validation
        IF p_first_name IS NULL OR p_last_name IS NULL OR p_email IS NULL THEN
            RAISE_APPLICATION_ERROR(-20001, 'Required fields cannot be null');
        END IF;
        
        INSERT INTO hydro_admin.customers (
            customer_id,
            first_name,
            last_name,
            email,
            phone,
            address
        ) VALUES (
            customers_seq.NEXTVAL,
            TRIM(p_first_name),
            TRIM(p_last_name),
            LOWER(TRIM(p_email)),
            p_phone,
            p_address
        );
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Customer registered: ' || p_first_name || ' ' || p_last_name);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error registering customer: ' || SQLERRM);
    END register_customer;

END customer_mgmt_pkg;
/

-- =============================================
-- Facility Management Package
-- =============================================
CREATE OR REPLACE PACKAGE hydro_admin.facility_mgmt_pkg IS
    -- Greenhouse management
    PROCEDURE setup_greenhouse(
        p_location IN VARCHAR2,
        p_total_slots IN NUMBER,
        p_greenhouse_id OUT NUMBER
    );
    
    -- Plant bed management
    PROCEDURE setup_plant_bed(
        p_slot_code IN VARCHAR2,
        p_capacity IN NUMBER,
        p_greenhouse_id IN NUMBER,
        p_crop_type_id IN NUMBER,
        p_growth_cycle_id IN NUMBER,
        p_planted_quantity IN NUMBER,
        p_plant_bed_id OUT NUMBER
    );
    
    -- Validation functions
    FUNCTION validate_greenhouse(p_greenhouse_id IN NUMBER) RETURN BOOLEAN;
END facility_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY hydro_admin.facility_mgmt_pkg IS
    PROCEDURE setup_greenhouse(
        p_location IN VARCHAR2,
        p_total_slots IN NUMBER,
        p_greenhouse_id OUT NUMBER
    ) IS
    BEGIN
        -- Input validation
        IF p_location IS NULL OR p_total_slots <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid greenhouse parameters');
        END IF;

        SELECT greenhouse_seq.NEXTVAL INTO p_greenhouse_id FROM DUAL;
        
        INSERT INTO hydro_admin.GREENHOUSES (
            GREENHOUSE_ID,
            LOCATION,
            TOTAL_SLOTS
        ) VALUES (
            p_greenhouse_id,
            TRIM(p_location),
            p_total_slots
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error setting up greenhouse: ' || SQLERRM);
    END setup_greenhouse;

    FUNCTION validate_greenhouse(
        p_greenhouse_id IN NUMBER
    ) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM hydro_admin.GREENHOUSES
        WHERE GREENHOUSE_ID = p_greenhouse_id;
        
        RETURN v_count > 0;
    END validate_greenhouse;

    PROCEDURE setup_plant_bed(
        p_slot_code IN VARCHAR2,
        p_capacity IN NUMBER,
        p_greenhouse_id IN NUMBER,
        p_crop_type_id IN NUMBER,
        p_growth_cycle_id IN NUMBER,
        p_planted_quantity IN NUMBER,
        p_plant_bed_id OUT NUMBER
    ) IS
    BEGIN
        -- Comprehensive validation
        IF NOT validate_greenhouse(p_greenhouse_id) THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid greenhouse ID');
        END IF;

        IF p_capacity <= 0 OR p_planted_quantity > p_capacity THEN
            RAISE_APPLICATION_ERROR(-20004, 'Invalid capacity or planted quantity');
        END IF;

        SELECT PLANT_BED_SEQ.NEXTVAL INTO p_plant_bed_id FROM DUAL;
        
        INSERT INTO hydro_admin.PLANT_BEDS (
            PLANT_BED_ID,
            SLOT_CODE,
            CAPACITY,
            GREENHOUSE_ID,
            CROP_TYPE_ID,
            GROWTH_CYCLE_ID,
            PLANTED_QUANTITY
        ) VALUES (
            p_plant_bed_id,
            TRIM(p_slot_code),
            p_capacity,
            p_greenhouse_id,
            p_crop_type_id,
            p_growth_cycle_id,
            p_planted_quantity
        );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20005, 'Error setting up plant bed: ' || SQLERRM);
    END setup_plant_bed;
END facility_mgmt_pkg;
/



-- =============================================
-- Order Management Package
-- =============================================
CREATE OR REPLACE PACKAGE order_mgmt_pkg IS
    -- Type definitions for order summary
    TYPE order_summary_rec IS RECORD (
        order_count NUMBER,
        total_revenue DECIMAL(15,2),
        avg_order_amount DECIMAL(15,2)
    );
    
    -- Procedure declarations
    PROCEDURE create_order(
        p_customer_id IN NUMBER,
        p_order_date IN DATE DEFAULT SYSDATE,
        p_new_order_id OUT NUMBER
    );
    
    PROCEDURE add_order_item(
        p_order_id IN NUMBER,
        p_harvest_id IN NUMBER,
        p_quantity_kg IN DECIMAL,
        p_order_item_id OUT NUMBER
    );
    
    PROCEDURE get_order_summary(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_summary OUT order_summary_rec
    );
END order_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY order_mgmt_pkg IS
    PROCEDURE create_order(
        p_customer_id IN NUMBER,
        p_order_date IN DATE DEFAULT SYSDATE,
        p_new_order_id OUT NUMBER
    ) IS
    BEGIN
        -- Get new order ID from sequence
        SELECT order_seq.NEXTVAL INTO p_new_order_id FROM DUAL;
        
        -- Insert new order
        INSERT INTO ORDERS (
            order_id, 
            customer_id, 
            order_date, 
            total_amount
        ) VALUES (
            p_new_order_id, 
            p_customer_id, 
            p_order_date, 
            0
        );
        
        -- Remove COMMIT to let calling procedure handle transaction control
    EXCEPTION
        WHEN OTHERS THEN
            -- Don't ROLLBACK here, let calling procedure handle it
            RAISE_APPLICATION_ERROR(-20001, 'Error creating order: ' || SQLERRM);
    END create_order;
PROCEDURE add_order_item(
    p_order_id IN NUMBER,
    p_harvest_id IN NUMBER,
    p_quantity_kg IN DECIMAL,
    p_order_item_id OUT NUMBER
) IS
    v_available_quantity DECIMAL(10,2);
    v_price_per_100g DECIMAL(10,2);
    v_crop_type_id NUMBER;
BEGIN
    -- Lock the HARVESTED_CROPS row first to prevent conflict with order updates
    SELECT available_quantity_kg, crop_type_id 
    INTO v_available_quantity, v_crop_type_id
    FROM HARVESTED_CROPS 
    WHERE harvest_id = p_harvest_id
    FOR UPDATE NOWAIT;  -- Avoid waiting indefinitely if locked by another session

    IF v_available_quantity < p_quantity_kg THEN
        -- If the quantity is insufficient, raise an error
        RAISE_APPLICATION_ERROR(-20002, 'Insufficient quantity available');
    END IF;

    -- Get price for the crop type
    SELECT price_per_100g 
    INTO v_price_per_100g
    FROM CROP_TYPES 
    WHERE crop_type_id = v_crop_type_id;

    -- Get new order item ID from sequence
    SELECT order_item_seq.NEXTVAL INTO p_order_item_id FROM DUAL;

    -- Insert order item
    INSERT INTO ORDER_ITEMS (
        order_item_id, 
        order_id, 
        harvest_id, 
        quantity_kg
    ) VALUES (
        p_order_item_id, 
        p_order_id, 
        p_harvest_id, 
        p_quantity_kg
    );

    -- Update available quantity in HARVESTED_CROPS
    UPDATE HARVESTED_CROPS
    SET available_quantity_kg = available_quantity_kg - p_quantity_kg
    WHERE harvest_id = p_harvest_id;

    -- Update order total in ORDERS
    UPDATE ORDERS
    SET total_amount = total_amount + (p_quantity_kg * 10 * v_price_per_100g)
    WHERE order_id = p_order_id;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;  -- Rollback the transaction in case of error
        IF SQLCODE = -54 THEN  -- ORA-00054: resource busy
            RAISE_APPLICATION_ERROR(-20003, 'Resource busy, try again later');
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Error adding order item: ' || SQLERRM);
        END IF;
END add_order_item;

    PROCEDURE get_order_summary(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_summary OUT order_summary_rec
    ) IS
    BEGIN
        SELECT 
            COUNT(*),
            SUM(total_amount),
            AVG(total_amount)
        INTO 
            p_summary.order_count,
            p_summary.total_revenue,
            p_summary.avg_order_amount
        FROM ORDERS
        WHERE order_date BETWEEN p_start_date AND p_end_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_summary := NULL;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20004, 'Error getting order summary: ' || SQLERRM);
    END get_order_summary;
END order_mgmt_pkg;
/

-- =============================================
-- Sensor Management Package
-- =============================================
CREATE OR REPLACE PACKAGE sensor_mgmt_pkg IS
    -- Type definition for sensor statistics
    TYPE sensor_stats_rec IS RECORD (
        avg_reading DECIMAL(10,2),
        min_reading DECIMAL(10,2),
        max_reading DECIMAL(10,2)
    );
    
    -- Procedure declarations
    PROCEDURE install_sensor(
        p_plant_bed_id IN NUMBER,
        p_sensor_type IN VARCHAR2,
        p_sensor_id OUT NUMBER
    );
    
    PROCEDURE log_sensor_reading(
        p_sensor_id IN NUMBER,
        p_reading_value IN DECIMAL
    );
    
    PROCEDURE get_sensor_statistics(
        p_plant_bed_id IN NUMBER,
        p_start_date IN TIMESTAMP,
        p_end_date IN TIMESTAMP,
        p_stats OUT sensor_stats_rec
    );
END sensor_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY sensor_mgmt_pkg IS
    PROCEDURE install_sensor(
        p_plant_bed_id IN NUMBER,
        p_sensor_type IN VARCHAR2,
        p_sensor_id OUT NUMBER
    ) IS
    BEGIN
        -- Get new sensor ID from sequence
        SELECT sensor_seq.NEXTVAL INTO p_sensor_id FROM DUAL;
        
        -- Install sensor
        INSERT INTO SENSORS (
            sensor_id, 
            plant_bed_id, 
            sensor_type, 
            installation_date
        ) VALUES (
            p_sensor_id, 
            p_plant_bed_id, 
            p_sensor_type, 
            SYSDATE
        );
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20006, 'Error installing sensor: ' || SQLERRM);
    END install_sensor;

    PROCEDURE log_sensor_reading(
        p_sensor_id IN NUMBER,
        p_reading_value IN DECIMAL
    ) IS
        v_log_id NUMBER;
    BEGIN
        -- Get new log ID from sequence
        SELECT sensor_log_seq.NEXTVAL INTO v_log_id FROM DUAL;
        
        -- Log reading
        INSERT INTO SENSOR_LOGS (
            log_id, 
            sensor_id, 
            timestamp, 
            reading_value
        ) VALUES (
            v_log_id, 
            p_sensor_id, 
            SYSTIMESTAMP, 
            p_reading_value
        );
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20007, 'Error logging sensor reading: ' || SQLERRM);
    END log_sensor_reading;

    PROCEDURE get_sensor_statistics(
        p_plant_bed_id IN NUMBER,
        p_start_date IN TIMESTAMP,
        p_end_date IN TIMESTAMP,
        p_stats OUT sensor_stats_rec
    ) IS
    BEGIN
        SELECT 
            AVG(sl.reading_value),
            MIN(sl.reading_value),
            MAX(sl.reading_value)
        INTO 
            p_stats.avg_reading,
            p_stats.min_reading,
            p_stats.max_reading
        FROM SENSOR_LOGS sl
        JOIN SENSORS s ON sl.sensor_id = s.sensor_id
        WHERE s.plant_bed_id = p_plant_bed_id
        AND sl.timestamp BETWEEN p_start_date AND p_end_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_stats := NULL;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20008, 'Error getting sensor statistics: ' || SQLERRM);
    END get_sensor_statistics;
END sensor_mgmt_pkg;
/



-- =============================================
-- Harvest Management Package 
-- =============================================

CREATE OR REPLACE PACKAGE harvest_mgmt_pkg IS
    FUNCTION get_harvest_status(
        p_growth_cycle_id IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION get_available_inventory(
        p_crop_type_id IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE get_harvest_report(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_report_cursor OUT SYS_REFCURSOR
        
    );
    PROCEDURE update_growth_cycle_stage(
    p_growth_cycle_id IN NUMBER,
    p_new_stage IN VARCHAR2
);
END harvest_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY harvest_mgmt_pkg IS
    FUNCTION get_harvest_status(
        p_growth_cycle_id IN NUMBER
    ) RETURN VARCHAR2 IS
        v_status VARCHAR2(100);
        v_stage VARCHAR2(50);
        v_start_date DATE;
        v_harvest_time NUMBER;
    BEGIN
        SELECT gc.stage, gc.start_date, ct.harvest_time_days
        INTO v_stage, v_start_date, v_harvest_time
        FROM growth_cycle gc, crop_types ct 
        WHERE gc.growth_cycle_id = p_growth_cycle_id
        AND gc.crop_type_id = ct.crop_type_id;
        
        IF v_stage = 'Harvest' THEN 
            v_status := 'Ready for harvest';
        ELSE
            v_status := 'In ' || v_stage || ' stage. Days until harvest: ' || 
                       TO_CHAR(v_harvest_time - (SYSDATE - v_start_date));
        END IF;
        
        RETURN v_status;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Growth cycle not found';
    END get_harvest_status;

    FUNCTION get_available_inventory(
        p_crop_type_id IN NUMBER
    ) RETURN NUMBER IS
        v_quantity NUMBER;
    BEGIN
        SELECT NVL(SUM(available_quantity_kg), 0)
        INTO v_quantity
        FROM harvested_crops
        WHERE crop_type_id = p_crop_type_id
        AND available_quantity_kg > 0;
        
        RETURN v_quantity;
    END get_available_inventory;

    PROCEDURE get_harvest_report(
        p_start_date IN DATE,
        p_end_date IN DATE,
        p_report_cursor OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN p_report_cursor FOR
            SELECT 
                ct.crop_name,
                COUNT(*) as harvest_count,
                SUM(hc.quantity_kg) as total_quantity,
                SUM(hc.quantity_kg * ct.price_per_100g * 10) as potential_revenue
            FROM harvested_crops hc, crop_types ct 
            WHERE hc.crop_type_id = ct.crop_type_id
            AND hc.harvest_date BETWEEN p_start_date AND p_end_date
            GROUP BY ct.crop_name
            ORDER BY SUM(hc.quantity_kg * ct.price_per_100g * 10) DESC;
    END get_harvest_report;
PROCEDURE update_growth_cycle_stage(
        p_growth_cycle_id IN NUMBER,
        p_new_stage IN VARCHAR2
    ) IS
        v_current_stage VARCHAR2(50);
        v_valid_stages VARCHAR2(200) := 'Seedling,Vegetative,Flowering,Harvest';
        v_plant_bed_id NUMBER;
        v_crop_name VARCHAR2(50);
        v_log_message VARCHAR2(4000);
    BEGIN
        -- Validate stage value
        IF INSTR(v_valid_stages, p_new_stage) = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid growth stage: ' || p_new_stage);
        END IF;
        
        -- Get current stage and crop details for logging
        SELECT gc.stage, gc.plant_bed_id, ct.crop_name
        INTO v_current_stage, v_plant_bed_id, v_crop_name
        FROM growth_cycle gc
        JOIN crop_types ct ON gc.crop_type_id = ct.crop_type_id
        WHERE gc.growth_cycle_id = p_growth_cycle_id;
        
        -- Only update if stage has changed
        IF v_current_stage != p_new_stage THEN
            -- Update the growth cycle stage first
            UPDATE growth_cycle
            SET stage = p_new_stage
            WHERE growth_cycle_id = p_growth_cycle_id;
            
            -- Format log message
            v_log_message := 'Plant Bed ' || v_plant_bed_id || ' - ' || v_crop_name || 
                            ' progressed from ' || v_current_stage || ' to ' || p_new_stage;
            
            -- Log using DBMS_OUTPUT for now (can be enhanced with proper logging later)
            DBMS_OUTPUT.PUT_LINE('Stage Change: ' || v_log_message);
        END IF;
        
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Growth cycle not found: ' || p_growth_cycle_id);
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Error updating growth cycle stage: ' || SQLERRM);
    END update_growth_cycle_stage;


END harvest_mgmt_pkg;
/



-- =============================================
--  Triggers 
-- =============================================
CREATE OR REPLACE TRIGGER trg_growth_cycle_stage_change
AFTER UPDATE ON growth_cycle
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_planted_quantity NUMBER;
    v_crop_type_id NUMBER;
    v_growth_cycle_id NUMBER;
    v_harvest_time NUMBER;
    v_simulation_date DATE;
BEGIN
    -- Only process when entering harvest stage
    IF :NEW.stage = 'Harvest' AND :OLD.stage != 'Harvest' THEN
        -- Get the current simulation date from the updated growth cycle
        v_simulation_date := TRUNC(:NEW.end_date);
        
        -- Get the planted quantity from plant bed
        SELECT planted_quantity 
        INTO v_planted_quantity
        FROM plant_beds
        WHERE plant_bed_id = :NEW.plant_bed_id;
        
        -- Create harvest record
        INSERT INTO harvested_crops (
            harvest_id,
            crop_type_id,
            harvest_date,
            quantity_kg,
            available_quantity_kg,
            growth_cycle_id
        ) VALUES (
            harvest_seq.NEXTVAL,
            :NEW.crop_type_id,
            v_simulation_date,  -- Use simulation date
            v_planted_quantity * 0.1,
            v_planted_quantity * 0.1,
            :NEW.growth_cycle_id
        );

        -- Clear the plant bed
        UPDATE plant_beds
        SET crop_type_id = NULL,
            growth_cycle_id = NULL,
            planted_quantity = 0
        WHERE plant_bed_id = :NEW.plant_bed_id;

        -- Select new random crop type for replanting
        SELECT crop_type_id, harvest_time_days 
        INTO v_crop_type_id, v_harvest_time
        FROM (
            SELECT crop_type_id, harvest_time_days 
            FROM crop_types 
            ORDER BY DBMS_RANDOM.VALUE
        ) WHERE ROWNUM = 1;

        -- Create new growth cycle using simulation date
        INSERT INTO growth_cycle (
            growth_cycle_id,
            crop_type_id,
            plant_bed_id,
            stage,
            start_date,
            end_date
        ) VALUES (
            growth_cycle_seq.NEXTVAL,
            v_crop_type_id,
            :NEW.plant_bed_id,
            'Seedling',
            v_simulation_date,  -- Use simulation date for start
            v_simulation_date + v_harvest_time  -- Calculate end date from simulation date
        ) RETURNING growth_cycle_id INTO v_growth_cycle_id;

        -- Update plant bed with new crop
        UPDATE plant_beds 
        SET crop_type_id = v_crop_type_id,
            growth_cycle_id = v_growth_cycle_id,
            planted_quantity = 100
        WHERE plant_bed_id = :NEW.plant_bed_id;

        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Harvested crop from bed ' || :NEW.plant_bed_id || 
                           ' - Yield: ' || (v_planted_quantity * 0.1) || 'kg' ||
                           ' on ' || TO_CHAR(v_simulation_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Planted new crop in bed ' || :NEW.plant_bed_id || 
                           ' with growth cycle ID ' || v_growth_cycle_id ||
                           ' starting ' || TO_CHAR(v_simulation_date, 'DD-MON-YYYY'));
    END IF;
END;
/


-- ============================================= 
-- Grants and Synonyms
-- =============================================

-- Grant package execution rights
GRANT EXECUTE ON hydro_admin.customer_mgmt_pkg TO sales_manager_role;
GRANT EXECUTE ON hydro_admin.facility_mgmt_pkg TO hydro_admin, agronomist_role;
GRANT EXECUTE ON hydro_admin.crop_mgmt_pkg TO agronomist_role;
GRANT EXECUTE ON harvest_mgmt_pkg TO agronomist_role;
GRANT EXECUTE ON sensor_mgmt_pkg TO agronomist_role, technician_role;
GRANT EXECUTE ON order_mgmt_pkg TO sales_manager_role;

-- Grant sequence access
GRANT SELECT ON hydro_admin.customers_seq TO sales_manager_role;
GRANT SELECT ON hydro_admin.greenhouse_seq TO hydro_admin;
GRANT SELECT ON hydro_admin.plant_bed_seq TO agronomist_role;
GRANT SELECT ON hydro_admin.crop_type_seq TO agronomist_role;
GRANT SELECT ON hydro_admin.growth_cycle_seq TO agronomist_role;
GRANT SELECT ON hydro_admin.order_seq TO sales_manager_role;
GRANT SELECT ON hydro_admin.order_item_seq TO sales_manager_role;
GRANT SELECT ON hydro_admin.harvest_seq TO agronomist_role;
GRANT SELECT ON hydro_admin.sensor_seq TO technician_role;
GRANT SELECT ON hydro_admin.sensor_log_seq TO technician_role;

-- Create public synonyms
CREATE OR REPLACE PUBLIC SYNONYM customer_mgmt FOR hydro_admin.customer_mgmt_pkg;
CREATE OR REPLACE PUBLIC SYNONYM facility_mgmt FOR hydro_admin.facility_mgmt_pkg;
CREATE OR REPLACE PUBLIC SYNONYM crop_mgmt FOR hydro_admin.crop_mgmt_pkg;
CREATE OR REPLACE PUBLIC SYNONYM order_mgmt FOR order_mgmt_pkg;
CREATE OR REPLACE PUBLIC SYNONYM harvest_mgmt FOR harvest_mgmt_pkg;
CREATE OR REPLACE PUBLIC SYNONYM sensor_mgmt FOR sensor_mgmt_pkg;
