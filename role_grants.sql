-- Technician privileges
GRANT SELECT ON hydro_admin.PLANT_BEDS TO technician_role;
GRANT SELECT ON hydro_admin.CROP_TYPES TO technician_role;
GRANT SELECT, INSERT, UPDATE ON hydro_admin.SENSORS TO technician_role;
GRANT SELECT, INSERT, UPDATE ON hydro_admin.SENSOR_LOGS TO technician_role;
GRANT SELECT ON hydro_admin.GROWTH_CYCLE TO technician_role;

-- Agronomist privileges
GRANT SELECT, INSERT, UPDATE ON hydro_admin.PLANT_BEDS TO agronomist_role;
GRANT SELECT, INSERT, UPDATE ON hydro_admin.CROP_TYPES TO agronomist_role;
GRANT SELECT, INSERT, UPDATE ON hydro_admin.GROWTH_CYCLE TO agronomist_role;
GRANT SELECT, INSERT, UPDATE ON hydro_admin.SENSOR_LOGS TO agronomist_role;
GRANT SELECT, INSERT ON hydro_admin.HARVESTED_CROPS TO agronomist_role;

-- Sales Manager privileges
GRANT SELECT, UPDATE ON hydro_admin.HARVESTED_CROPS TO sales_manager_role;
GRANT SELECT,INSERT, UPDATE ON hydro_admin.ORDERS TO sales_manager_role;
GRANT SELECT,INSERT, UPDATE ON hydro_admin.ORDER_ITEMS TO sales_manager_role;
GRANT SELECT,INSERT, UPDATE ON hydro_admin.CUSTOMERS TO sales_manager_role;

