CREATE OR REPLACE PACKAGE hydro_admin.simulation_pkg IS
    PROCEDURE generate_sensor_readings;
    PROCEDURE progress_growth_cycles;
    PROCEDURE simulate_week;
END simulation_pkg;
/

CREATE OR REPLACE PACKAGE hydro_admin.simulation_pkg IS
    PROCEDURE simulate_week(p_current_date IN DATE DEFAULT SYSDATE);
END simulation_pkg;
/

CREATE OR REPLACE PACKAGE BODY hydro_admin.simulation_pkg IS
   PROCEDURE generate_sensor_readings(p_current_date IN DATE) IS
        v_reading_value NUMBER;
        v_log_id NUMBER;
    BEGIN
        FOR sensor_rec IN (
            SELECT sensor_id, sensor_type 
            FROM sensors 
            WHERE sensor_type IN ('TEMPERATURE', 'HUMIDITY', 'PH')
        ) LOOP
            -- Calculate reading value based on sensor type
            CASE sensor_rec.sensor_type
                WHEN 'TEMPERATURE' THEN 
                    v_reading_value := 22 + DBMS_RANDOM.VALUE(-2, 2);
                WHEN 'HUMIDITY' THEN
                    v_reading_value := 65 + DBMS_RANDOM.VALUE(-5, 5);
                WHEN 'PH' THEN
                    v_reading_value := 6 + DBMS_RANDOM.VALUE(-0.3, 0.3);
            END CASE;

            -- Use the package procedure to log the reading
            sensor_mgmt_pkg.log_sensor_reading(
                p_sensor_id => sensor_rec.sensor_id,
                p_reading_value => ROUND(v_reading_value, 2),
                p_timestamp => CAST(p_current_date AS TIMESTAMP),
                p_log_id => v_log_id
            );
        END LOOP;
    END generate_sensor_readings;
    
    PROCEDURE progress_growth_cycles(p_current_date IN DATE) IS
        CURSOR growth_cur IS
            SELECT 
                gc.growth_cycle_id,
                gc.start_date,
                gc.stage,
                gc.crop_type_id,
                ct.harvest_time_days,
                ct.crop_name,
                ROUND(((p_current_date - gc.start_date) / ct.harvest_time_days) * 100) as progress_pct
            FROM growth_cycle gc
            JOIN crop_types ct ON gc.crop_type_id = ct.crop_type_id
            WHERE gc.stage != 'Harvest';
            
        v_rec growth_cur%ROWTYPE;
        v_new_stage VARCHAR2(50);
        v_growth_cycle_id NUMBER;
    BEGIN
        OPEN growth_cur;
        LOOP
            FETCH growth_cur INTO v_rec;
            EXIT WHEN growth_cur%NOTFOUND;
            
            -- Log the current progress
            DBMS_OUTPUT.PUT_LINE('Growth Cycle ' || v_rec.growth_cycle_id || 
                               ' (' || v_rec.crop_name || ')' ||
                               ': Progress ' || v_rec.progress_pct || '%' ||
                               ', Current Stage: ' || v_rec.stage ||
                               ', Days since start: ' || ROUND(p_current_date - v_rec.start_date) ||
                               ', Harvest time: ' || v_rec.harvest_time_days);

            -- Determine new stage based on progress percentage
            v_new_stage := 
                CASE 
                    WHEN v_rec.progress_pct < 30 THEN 'Seedling'
                    WHEN v_rec.progress_pct < 60 THEN 'Vegetative'
                    WHEN v_rec.progress_pct < 90 THEN 'Flowering'
                    ELSE 'Harvest'
                END;

            -- Update if stage has changed
            IF v_new_stage != v_rec.stage THEN
                DBMS_OUTPUT.PUT_LINE('Updating ' || v_rec.crop_name || ' from ' || 
                                   v_rec.stage || ' to ' || v_new_stage);
                
                -- Use crop management package to update growth cycle stage
                facility_mgmt_pkg.update_growth_cycle_stage(
                    p_growth_cycle_id => v_rec.growth_cycle_id,
                    p_new_stage => v_new_stage
                );
            END IF;
        END LOOP;
        CLOSE growth_cur;
    EXCEPTION
        WHEN OTHERS THEN
            IF growth_cur%ISOPEN THEN
                CLOSE growth_cur;
            END IF;
            RAISE;
    END progress_growth_cycles;
    
    PROCEDURE generate_daily_orders(p_simulation_date IN DATE) IS
    v_order_id NUMBER;
    v_order_item_id NUMBER;
    v_order_qty NUMBER;
    v_num_retail_customers NUMBER;
    v_retail_count NUMBER := 0;
BEGIN
    -- Process wholesale customers
    FOR wholesale_rec IN (
        SELECT customer_id 
        FROM customers 
        WHERE UPPER(last_name) = 'WHOLESALE'
    ) LOOP
        -- Generate 10-12 orders per wholesale customer
        FOR i IN 1..TRUNC(DBMS_RANDOM.VALUE(10, 13)) LOOP
            -- Create order using package procedure
            order_mgmt_pkg.create_order(
                p_customer_id => wholesale_rec.customer_id,
                p_order_date => p_simulation_date,
                p_new_order_id => v_order_id
            );
            
            -- Add 3-5 items per wholesale order
            FOR j IN 1..TRUNC(DBMS_RANDOM.VALUE(3, 6)) LOOP
                -- Try to add an item from available harvest
                FOR harvest_rec IN (
                    SELECT 
                        hc.harvest_id,
                        hc.available_quantity_kg
                    FROM harvested_crops hc
                    WHERE hc.available_quantity_kg > 0
                    ORDER BY DBMS_RANDOM.VALUE()
                ) LOOP
                    -- Calculate random order quantity (2-10 kg for wholesale)
                    v_order_qty := ROUND(DBMS_RANDOM.VALUE(2, 10), 1);
                    
                    IF harvest_rec.available_quantity_kg >= v_order_qty THEN
                        -- Add order item using package procedure
                        order_mgmt_pkg.add_order_item(
                            p_order_id => v_order_id,
                            p_harvest_id => harvest_rec.harvest_id,
                            p_quantity_kg => v_order_qty,
                            p_order_item_id => v_order_item_id
                        );
                        EXIT;  -- Move to next item
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;

    -- Randomly select 3-4 retail customers
    v_num_retail_customers := TRUNC(DBMS_RANDOM.VALUE(3, 5));
    
    -- Process retail customers
    FOR retail_rec IN (
        SELECT customer_id 
        FROM customers 
        WHERE UPPER(last_name) != 'WHOLESALE'
        ORDER BY DBMS_RANDOM.VALUE()
    ) LOOP
        v_retail_count := v_retail_count + 1;
        EXIT WHEN v_retail_count > v_num_retail_customers;
        
        -- Generate 1-2 orders per retail customer
        FOR i IN 1..TRUNC(DBMS_RANDOM.VALUE(1, 3)) LOOP
            -- Create order using package procedure
            order_mgmt_pkg.create_order(
                p_customer_id => retail_rec.customer_id,
                p_order_date => p_simulation_date,
                p_new_order_id => v_order_id
            );
            
            -- Add 1-3 items per retail order
            FOR j IN 1..TRUNC(DBMS_RANDOM.VALUE(1, 4)) LOOP
                -- Try to add an item from available harvest
                FOR harvest_rec IN (
                    SELECT 
                        hc.harvest_id,
                        hc.available_quantity_kg
                    FROM harvested_crops hc
                    WHERE hc.available_quantity_kg > 0
                    ORDER BY DBMS_RANDOM.VALUE()
                ) LOOP
                    -- Calculate random order quantity (0.5-2 kg for retail)
                    v_order_qty := ROUND(DBMS_RANDOM.VALUE(0.5, 2), 1);
                    
                    IF harvest_rec.available_quantity_kg >= v_order_qty THEN
                        -- Add order item using package procedure
                        order_mgmt_pkg.add_order_item(
                            p_order_id => v_order_id,
                            p_harvest_id => harvest_rec.harvest_id,
                            p_quantity_kg => v_order_qty,
                            p_order_item_id => v_order_item_id
                        );
                        EXIT;  -- Move to next item
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Error generating orders: ' || SQLERRM);
END generate_daily_orders;
    
    
    
    
    PROCEDURE simulate_week(p_current_date IN DATE DEFAULT SYSDATE) IS
        v_simulation_date DATE := p_current_date;
    BEGIN
        -- Simulate 7 days
        FOR i IN 1..7 LOOP
            DBMS_OUTPUT.PUT_LINE('=== Simulating ' || TO_CHAR(v_simulation_date, 'DD-MON-YYYY') || ' ===');
            
            generate_sensor_readings(v_simulation_date);
            progress_growth_cycles(v_simulation_date);
            generate_daily_orders(v_simulation_date);
            -- Advance to next day
            v_simulation_date := v_simulation_date + 1;
            
        END LOOP;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Error in simulate_week: ' || SQLERRM);
    END simulate_week;
END simulation_pkg;
/
---- Run for 4 weeks
DECLARE
    v_simulation_date DATE := SYSDATE;
BEGIN
    FOR week IN 1..4 LOOP
        DBMS_OUTPUT.PUT_LINE('=== Starting Week ' || week || ' ===');
        simulation_pkg.simulate_week(v_simulation_date);
        v_simulation_date := v_simulation_date + 7;  -- Advance to next week
    END LOOP;
END;
/

