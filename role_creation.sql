


-- Start an anonymous PL/SQL block to handle dropping roles and users
BEGIN
   -- Drop roles if they exist
   EXECUTE IMMEDIATE 'DROP ROLE admin_role';
   EXECUTE IMMEDIATE 'DROP ROLE technician_role';
   EXECUTE IMMEDIATE 'DROP ROLE agronomist_role';
   EXECUTE IMMEDIATE 'DROP ROLE sales_manager_role';
   EXECUTE IMMEDIATE 'DROP ROLE customer_role';
EXCEPTION
   WHEN OTHERS THEN
      NULL;  -- Ignore errors if roles do not exist
END;
/

-- Create hydro_admin user with admin_role if it does not already exist
BEGIN
    EXECUTE IMMEDIATE 'CREATE USER hydro_admin IDENTIFIED BY "Adminpassword20#"';
    EXECUTE IMMEDIATE 'GRANT admin_role TO hydro_admin';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -01920 THEN
            NULL; -- User already exists, do nothing
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    -- List the usernames you want to drop
    FOR user_rec IN (
        SELECT 'HYDRO_ADMIN' AS username FROM dual UNION ALL
        SELECT 'HYDRO_TECHNICIAN' FROM dual UNION ALL
        SELECT 'HYDRO_AGRONOMIST' FROM dual UNION ALL
        SELECT 'HYDRO_SALES_MANAGER' FROM dual
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP USER ' || user_rec.username || ' CASCADE';
            DBMS_OUTPUT.PUT_LINE('Dropped user: ' || user_rec.username);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop user ' || user_rec.username || ' due to: ' || SQLERRM);
        END;
    END LOOP;
END;
/
COMMIT;


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

-- Create Users and Assign Roles
-- Assumes roles admin_role, technician_role, agronomist_role, and sales_manager_role already exist with the required permissions

-- Create hydro_admin user with admin_role
CREATE USER hydro_admin IDENTIFIED BY "Adminpassword20#";
GRANT admin_role TO hydro_admin;

-- Create hydro_technician user with technician_role
CREATE USER hydro_technician IDENTIFIED BY "Techpassword20#";
GRANT technician_role TO hydro_technician;

-- Create hydro_agronomist user with agronomist_role
CREATE USER hydro_agronomist IDENTIFIED BY "Agripassword20#";
GRANT agronomist_role TO hydro_agronomist;

-- Create hydro_sales_manager user with sales_manager_role
CREATE USER hydro_sales_manager IDENTIFIED BY "Salespassword20#";
GRANT sales_manager_role TO hydro_sales_manager;
