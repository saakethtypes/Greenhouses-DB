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
                p_reading_value => ROUND(v_reading_value, 2)
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
                ROUND(abs((p_current_date - gc.start_date) / ct.harvest_time_days) * 100) as progress_pct
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
                harvest_mgmt_pkg.update_growth_cycle_stage(
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
    v_items_added BOOLEAN;
    v_successful BOOLEAN;
BEGIN
    -- Process wholesale customers (10-12 orders each)
    FOR wholesale IN (
        SELECT customer_id 
        FROM customers 
        WHERE UPPER(last_name) LIKE '%WHOLESALE%'
    ) LOOP
        -- Generate 10-12 orders per wholesale customer
        FOR i IN 1..TRUNC(DBMS_RANDOM.VALUE(10, 13)) LOOP
            v_items_added := FALSE;
            
            -- Create new order using package procedure
            BEGIN
                ORDER_MGMT_PKG.CREATE_ORDER(
                    P_CUSTOMER_ID => wholesale.customer_id,
                    P_ORDER_DATE => p_simulation_date,
                    P_NEW_ORDER_ID => v_order_id
                );
                
                -- Add 3-5 items per order
                FOR j IN 1..TRUNC(DBMS_RANDOM.VALUE(3, 6)) LOOP
                    v_successful := FALSE;
                    
                    -- Try different harvests until one succeeds or we run out of options
                    FOR harvest IN (
                        SELECT h.harvest_id, h.available_quantity_kg
                        FROM harvested_crops h
                        WHERE h.available_quantity_kg > 0
                        AND h.harvest_id NOT IN (
                            SELECT harvest_id FROM order_items 
                            WHERE order_id = v_order_id
                        )
                        ORDER BY DBMS_RANDOM.VALUE
                    ) LOOP
                        EXIT WHEN v_successful;
                        
                        BEGIN
                            -- Generate order quantity (2-10kg for wholesale)
                            v_order_qty := ROUND(DBMS_RANDOM.VALUE(2, LEAST(10, harvest.available_quantity_kg)), 1);
                            
                            -- Try to add order item
                            ORDER_MGMT_PKG.ADD_ORDER_ITEM(
                                P_ORDER_ID => v_order_id,
                                P_HARVEST_ID => harvest.harvest_id,
                                P_QUANTITY_KG => v_order_qty,
                                P_ORDER_ITEM_ID => v_order_item_id
                            );
                            
                            v_successful := TRUE;
                            v_items_added := TRUE;
                        EXCEPTION
                            WHEN OTHERS THEN
                                -- Just continue to next harvest
                                NULL;
                        END;
                    END LOOP;
                END LOOP;
                
            EXCEPTION
                WHEN OTHERS THEN
                    -- Log error and continue with next order
                    DBMS_OUTPUT.PUT_LINE('Error processing wholesale order: ' || SQLERRM);
            END;
        END LOOP;
    END LOOP;

    -- Process retail customers (3-4 random customers)
    FOR retail IN (
        SELECT customer_id 
        FROM customers 
        WHERE UPPER(last_name) NOT LIKE '%WHOLESALE%'
        ORDER BY DBMS_RANDOM.VALUE
        FETCH FIRST 4 ROWS ONLY
    ) LOOP
        -- Generate 1-2 orders per customer
        FOR i IN 1..TRUNC(DBMS_RANDOM.VALUE(1, 3)) LOOP
            v_items_added := FALSE;
            
            -- Create new order using package procedure
            BEGIN
                ORDER_MGMT_PKG.CREATE_ORDER(
                    P_CUSTOMER_ID => retail.customer_id,
                    P_ORDER_DATE => p_simulation_date,
                    P_NEW_ORDER_ID => v_order_id
                );
                
                -- Add 1-3 items per order
                FOR j IN 1..TRUNC(DBMS_RANDOM.VALUE(1, 4)) LOOP
                    v_successful := FALSE;
                    
                    -- Try different harvests until one succeeds or we run out of options
                    FOR harvest IN (
                        SELECT h.harvest_id, h.available_quantity_kg
                        FROM harvested_crops h
                        WHERE h.available_quantity_kg > 0
                        AND h.harvest_id NOT IN (
                            SELECT harvest_id FROM order_items 
                            WHERE order_id = v_order_id
                        )
                        ORDER BY DBMS_RANDOM.VALUE
                    ) LOOP
                        EXIT WHEN v_successful;
                        
                        BEGIN
                            -- Generate order quantity (0.5-2kg for retail)
                            v_order_qty := ROUND(DBMS_RANDOM.VALUE(0.5, LEAST(2, harvest.available_quantity_kg)), 1);
                            
                            -- Try to add order item
                            ORDER_MGMT_PKG.ADD_ORDER_ITEM(
                                P_ORDER_ID => v_order_id,
                                P_HARVEST_ID => harvest.harvest_id,
                                P_QUANTITY_KG => v_order_qty,
                                P_ORDER_ITEM_ID => v_order_item_id
                            );
                            
                            v_successful := TRUE;
                            v_items_added := TRUE;
                        EXCEPTION
                            WHEN OTHERS THEN
                                -- Just continue to next harvest
                                NULL;
                        END;
                    END LOOP;
                END LOOP;
                
            EXCEPTION
                WHEN OTHERS THEN
                    -- Log error and continue with next order
                    DBMS_OUTPUT.PUT_LINE('Error processing retail order: ' || SQLERRM);
            END;
        END LOOP;
    END LOOP;

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Orders generated for date: ' || TO_CHAR(p_simulation_date, 'DD-MON-YYYY'));
END generate_daily_orders;

    
PROCEDURE simulate_week(p_current_date IN DATE DEFAULT SYSDATE) IS
    v_simulation_date DATE := p_current_date;
BEGIN
    -- Simulate 7 days
    FOR i IN 1..7 LOOP
        DBMS_OUTPUT.PUT_LINE('=== Simulating ' || TO_CHAR(v_simulation_date, 'DD-MON-YYYY') || ' ===');
        
        -- Call to generate sensor readings, progress growth, and generate orders
        generate_sensor_readings(v_simulation_date);
        progress_growth_cycles(v_simulation_date);
        generate_daily_orders(v_simulation_date);
        
        -- Advance to next day
        v_simulation_date := v_simulation_date + 1;
        
    END LOOP;
    
    COMMIT;  -- Commit after all 7 days of simulation
EXCEPTION
    WHEN OTHERS THEN
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

