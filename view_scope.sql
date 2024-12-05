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


CREATE OR REPLACE PROCEDURE print_schema_objects IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== HYDRO_ADMIN Schema Objects ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Print Packages and their contents
    FOR pkg_rec IN (
        SELECT DISTINCT object_name 
        FROM user_objects 
        WHERE object_type = 'PACKAGE'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? Package: ' || pkg_rec.object_name);
        
        -- Get package procedures using ALL_PROCEDURES
        FOR proc_rec IN (
            SELECT DISTINCT subprogram_id, procedure_name
            FROM all_procedures
            WHERE object_type = 'PACKAGE'
            AND object_name = pkg_rec.object_name
            AND owner = USER
            AND procedure_name IS NOT NULL
            ORDER BY subprogram_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ?? ' || proc_rec.procedure_name);
            
            -- Get arguments for this procedure
            FOR arg_rec IN (
                SELECT argument_name, data_type, position, in_out
                FROM all_arguments
                WHERE package_name = pkg_rec.object_name
                AND object_name = proc_rec.procedure_name
                AND owner = USER
                ORDER BY position
            ) LOOP
                IF arg_rec.argument_name IS NOT NULL THEN
                    DBMS_OUTPUT.PUT_LINE('      ' || RPAD(arg_rec.argument_name, 30) || 
                                       ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
                END IF;
            END LOOP;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Standalone Procedures
    DBMS_OUTPUT.PUT_LINE('=== Standalone Procedures ===');
    FOR proc_rec IN (
        SELECT object_name 
        FROM user_objects 
        WHERE object_type = 'PROCEDURE'
        AND object_name NOT LIKE 'SYS_%'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || proc_rec.object_name);
        
        -- Get procedure arguments
        FOR arg_rec IN (
            SELECT argument_name, data_type, position, in_out
            FROM all_arguments
            WHERE object_name = proc_rec.object_name
            AND package_name IS NULL
            AND owner = USER
            ORDER BY position
        ) LOOP
            IF arg_rec.argument_name IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('    ' || RPAD(arg_rec.argument_name, 30) || 
                                   ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Functions
    DBMS_OUTPUT.PUT_LINE('=== Functions ===');
    FOR func_rec IN (
        SELECT object_name 
        FROM user_objects 
        WHERE object_type = 'FUNCTION'
        AND object_name NOT LIKE 'SYS_%'
        ORDER BY object_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || func_rec.object_name);
        
        -- Get function arguments
        FOR arg_rec IN (
            SELECT argument_name, data_type, position, in_out
            FROM all_arguments
            WHERE object_name = func_rec.object_name
            AND package_name IS NULL
            AND owner = USER
            ORDER BY position
        ) LOOP
            IF arg_rec.argument_name IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('    ' || RPAD(arg_rec.argument_name, 30) || 
                                   ' ' || arg_rec.in_out || ' ' || arg_rec.data_type);
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    -- Print Triggers
    DBMS_OUTPUT.PUT_LINE('=== Triggers ===');
    FOR trg_rec IN (
        SELECT trigger_name, triggering_event, table_name, status
        FROM user_triggers
        WHERE trigger_name NOT LIKE 'SYS_%'
        ORDER BY trigger_name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('? ' || trg_rec.trigger_name);
        DBMS_OUTPUT.PUT_LINE('    Table: ' || trg_rec.table_name);
        DBMS_OUTPUT.PUT_LINE('    Event: ' || trg_rec.triggering_event);
        DBMS_OUTPUT.PUT_LINE('    Status: ' || trg_rec.status);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;
/

-- Execute the procedure
BEGIN
    print_schema_objects;
END;
/
