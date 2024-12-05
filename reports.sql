--Crop Management Report
--Provides details about a crop type, including growing conditions, harvest time, and price.
DECLARE
    v_crop_details hydro_admin.crop_mgmt_pkg.crop_details_rec;
BEGIN
    -- Call GET_CROP_DETAILS function from CROP_MGMT_PKG
    v_crop_details := hydro_admin.crop_mgmt_pkg.get_crop_details(p_crop_type_id => 1);

    -- Display the crop details
    DBMS_OUTPUT.PUT_LINE('Crop Name: ' || v_crop_details.crop_name);
    DBMS_OUTPUT.PUT_LINE('Growing Conditions: ' || v_crop_details.growing_conditions);
    DBMS_OUTPUT.PUT_LINE('Harvest Time (Days): ' || v_crop_details.harvest_time_days);
    DBMS_OUTPUT.PUT_LINE('Price per 100g: ' || v_crop_details.price_per_100g);
END;




--Harvest Inventory Report
--Generates a report of available inventory for a specific crop type.
DECLARE
    v_available_inventory NUMBER;
BEGIN
    -- Call GET_AVAILABLE_INVENTORY function from HARVEST_MGMT_PKG
    v_available_inventory := hydro_admin.harvest_mgmt_pkg.get_available_inventory(p_crop_type_id => 1);

    -- Display the available inventory
    DBMS_OUTPUT.PUT_LINE('Available Inventory for Crop Type 1: ' || v_available_inventory || ' kg');
END;




--Greenhouse Report
--Purpose: Displays all greenhouses with their total slots and plant bed details.
CREATE OR REPLACE VIEW greenhouse_report AS
SELECT 
    g.greenhouse_id,
    g.location AS greenhouse_location,
    g.total_slots,
    pb.plant_bed_id,
    pb.slot_code,
    pb.capacity,
    pb.planted_quantity
FROM 
    greenhouses g
JOIN 
    plant_beds pb ON g.greenhouse_id = pb.greenhouse_id
ORDER BY 
    g.greenhouse_id, pb.plant_bed_id;


SELECT * FROM greenhouse_report;




--Order Summary
--Purpose: Generates a summary of orders, including total amount and quantity.
CREATE OR REPLACE VIEW order_summary_report AS
SELECT 
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(oi.quantity_kg) AS total_quantity_kg,
    o.total_amount
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id, o.order_date, c.first_name, c.last_name
ORDER BY 
    o.order_date DESC;







SELECT * FROM order_summary_report;

--Monthly Revenue Report
--Purpose: Provides monthly revenue based on customer orders.
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') AS order_month,
    SUM(o.total_amount) AS total_revenue,
    COUNT(o.order_id) AS total_orders
FROM 
    ORDERS o
GROUP BY 
    TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY 
    order_month ASC;





