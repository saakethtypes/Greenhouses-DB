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
