CREATE OR REPLACE PACKAGE hydro_admin.initial_data_pkg IS
    PROCEDURE populate_base_data;
END initial_data_pkg;
/

CREATE OR REPLACE PACKAGE BODY hydro_admin.initial_data_pkg IS
    PROCEDURE populate_base_data IS
        -- Variables to store IDs
        v_greenhouse_id NUMBER;
        v_crop_type_id NUMBER;
        v_plant_bed_id NUMBER;
        v_sensor_id NUMBER;
        v_growth_cycle_id NUMBER;
        v_harvest_time NUMBER;
        
    BEGIN
        -- 1. Create Greenhouses
        DBMS_OUTPUT.PUT_LINE('Creating Greenhouses...');
        facility_mgmt_pkg.setup_greenhouse('Miami', 6, v_greenhouse_id);
        facility_mgmt_pkg.setup_greenhouse('Boston', 5, v_greenhouse_id);
        facility_mgmt_pkg.setup_greenhouse('Phoenix', 5, v_greenhouse_id);

        -- 2. Create Crop Types
        DBMS_OUTPUT.PUT_LINE('Creating Crop Types...');
        crop_mgmt_pkg.insert_crop_type('Premium Lettuce', 'Temp: 18-21°C, Humidity: 60-70%, pH: 6.0-6.5', 14, 3.50, v_crop_type_id);
        crop_mgmt_pkg.insert_crop_type('Cherry Tomatoes', 'Temp: 20-25°C, Humidity: 65-75%, pH: 5.5-6.5', 21, 4.25, v_crop_type_id);
        crop_mgmt_pkg.insert_crop_type('English Cucumber', 'Temp: 22-28°C, Humidity: 70-80%, pH: 5.5-6.0', 25, 3.75, v_crop_type_id);
        crop_mgmt_pkg.insert_crop_type('Fresh Basil', 'Temp: 20-25°C, Humidity: 60-65%, pH: 5.5-6.5', 17, 5.00, v_crop_type_id);
        crop_mgmt_pkg.insert_crop_type('Baby Spinach', 'Temp: 16-20°C, Humidity: 60-70%, pH: 6.0-7.0', 7, 4.50, v_crop_type_id);
--        crop_mgmt_pkg.insert_crop_type('Bell Peppers', 'Temp: 20-25°C, Humidity: 65-75%, pH: 5.5-6.5', 30, 4.75, v_crop_type_id);

        -- 3. Create Customers (sales_manager_role)
        DBMS_OUTPUT.PUT_LINE('Creating Customers...');
        customer_mgmt_pkg.register_customer('Michael', 'Thompson', 'm.thompson@email.com', '555-0101', '123 Market St, Miami, FL');
        customer_mgmt_pkg.register_customer('Sarah', 'Rodriguez', 's.rodriguez@email.com', '555-0102', '456 Ocean Dr, Miami, FL');
        customer_mgmt_pkg.register_customer('James', 'Wilson', 'j.wilson@email.com', '555-0103', '789 Beacon St, Boston, MA');
        customer_mgmt_pkg.register_customer('Emily', 'Chen', 'e.chen@email.com', '555-0104', '321 Newbury St, Boston, MA');
        customer_mgmt_pkg.register_customer('David', 'Miller', 'd.miller@email.com', '555-0105', '654 Camelback Rd, Phoenix, AZ');
        customer_mgmt_pkg.register_customer('Fresh', 'Wholesale', 'orders@freshwholesale.com', '555-9001', '789 Distribution Ave, Miami, FL');
        customer_mgmt_pkg.register_customer('Green', 'Wholesale', 'buying@greenwholesale.com', '555-9002', '456 Market St, Boston, MA');
        customer_mgmt_pkg.register_customer('Prime', 'Wholesale', 'orders@primewholesale.com', '555-9003', '123 Commerce Dr, Phoenix, AZ');
        customer_mgmt_pkg.register_customer('Sarah', 'Johnson', 's.johnson@email.com', '555-0201', '789 Pine St, Miami, FL');
        customer_mgmt_pkg.register_customer('Michael', 'Chen', 'm.chen@email.com', '555-0202', '321 Oak Ave, Boston, MA');
        customer_mgmt_pkg.register_customer('Emily', 'Brown', 'e.brown@email.com', '555-0203', '456 Maple Dr, Phoenix, AZ');
        customer_mgmt_pkg.register_customer('Lisa', 'Taylor', 'l.taylor@email.com', '555-0205', '654 Birch Rd, Boston, MA');

        -- 4. Create Plant Beds
        DBMS_OUTPUT.PUT_LINE('Creating Plant Beds...');
        -- Miami Plant Beds
        FOR i IN 1..6 LOOP
            facility_mgmt_pkg.setup_plant_bed(
                'MIA-' || LPAD(i, 2, '0'),
                100,
                1,  -- Greenhouse 1 (Miami)
                NULL, NULL, 0,
                v_plant_bed_id
            );
        END LOOP;

        -- Boston Plant Beds
        FOR i IN 1..5 LOOP
            facility_mgmt_pkg.setup_plant_bed(
                'BOS-' || LPAD(i, 2, '0'),
                100,
                2,  -- Greenhouse 2 (Boston)
                NULL, NULL, 0,
                v_plant_bed_id
            );
        END LOOP;

        -- Phoenix Plant Beds
        FOR i IN 1..5 LOOP
            facility_mgmt_pkg.setup_plant_bed(
                'PHX-' || LPAD(i, 2, '0'),
                100,
                3,  -- Greenhouse 3 (Phoenix)
                NULL, NULL, 0,
                v_plant_bed_id
            );
        END LOOP;

        -- 5. Install Sensors
        DBMS_OUTPUT.PUT_LINE('Installing Sensors...');
        FOR bed IN (SELECT plant_bed_id FROM plant_beds) LOOP
            sensor_mgmt_pkg.install_sensor(bed.plant_bed_id, 'TEMPERATURE', v_sensor_id);
            sensor_mgmt_pkg.install_sensor(bed.plant_bed_id, 'HUMIDITY', v_sensor_id);
            sensor_mgmt_pkg.install_sensor(bed.plant_bed_id, 'PH', v_sensor_id);
        END LOOP;

        -- 6. Create Initial Growth Cycles (randomly assign crops to some plant beds)
            DBMS_OUTPUT.PUT_LINE('Creating Initial Growth Cycles...');
            FOR bed IN (
                SELECT plant_bed_id 
                FROM plant_beds 
                WHERE ROWNUM <= 8  -- Start with 8 random plant beds
                ORDER BY DBMS_RANDOM.VALUE
            ) LOOP
                -- Get random crop type with its harvest time
                SELECT crop_type_id, harvest_time_days 
                INTO v_crop_type_id, v_harvest_time
                FROM (
                    SELECT crop_type_id, harvest_time_days
                    FROM crop_types 
                    ORDER BY DBMS_RANDOM.VALUE
                ) WHERE ROWNUM = 1;
            
                -- Create growth cycle using the crop's specific harvest time
                crop_mgmt_pkg.insert_growth_cycle(
                    v_crop_type_id,
                    bed.plant_bed_id,
                    'Seedling',
                    SYSDATE,
                    SYSDATE + v_harvest_time,  -- Using crop-specific harvest time
                    v_growth_cycle_id
                );
            
                -- Update plant bed with crop and quantity
                UPDATE plant_beds 
                SET crop_type_id = v_crop_type_id,
                    growth_cycle_id = v_growth_cycle_id,
                    planted_quantity = 100
                WHERE plant_bed_id = bed.plant_bed_id;
            END LOOP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Initial data population completed successfully.');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            RAISE;
    END populate_base_data;
END initial_data_pkg;
/

-- Grant execute permissions
GRANT EXECUTE ON hydro_admin.initial_data_pkg TO agronomist_role;

-- Execute the population
EXEC hydro_admin.initial_data_pkg.populate_base_data;




---------------------------------------
select * from plant_beds;
