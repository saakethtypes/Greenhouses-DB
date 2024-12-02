-- View: Customer Total Purchase History
CREATE OR REPLACE VIEW Customer_Total_Purchase_History AS
SELECT 
       c.customer_id, 
       c.first_name, 
       c.last_name, 
       SUM(oi.quantity_kg * ct.price_per_100g * 10) AS total_purchase_value
FROM 
       hydro_admin.Customers c
JOIN 
       hydro_admin.Orders o ON c.customer_id = o.customer_id
JOIN 
       hydro_admin.Order_Items oi ON o.order_id = oi.order_id
JOIN 
       hydro_admin.Harvested_Crops hc ON oi.harvest_id = hc.harvest_id
JOIN 
       hydro_admin.Crop_Types ct ON hc.crop_type_id = ct.crop_type_id
GROUP BY 
       c.customer_id, c.first_name, c.last_name
ORDER BY 
       total_purchase_value DESC;



-- View: Monthly Sales by Crop (total_revenue with $ sign at the end)
CREATE OR REPLACE VIEW Monthly_Sales_By_Crop AS
SELECT 
       ct.crop_name, 
       TO_CHAR(o.order_date, 'YYYY-MM') AS sale_month,
       SUM(oi.quantity_kg) AS total_quantity_sold,
       TO_CHAR(ROUND(SUM(oi.quantity_kg * ct.price_per_100g * 10), 2), '99999.99') || ' $' AS total_revenue
FROM 
       Orders o
JOIN 
       Order_Items oi ON o.order_id = oi.order_id
JOIN 
       Harvested_Crops hc ON oi.harvest_id = hc.harvest_id
JOIN 
       Crop_Types ct ON hc.crop_type_id = ct.crop_type_id
GROUP BY 
       ct.crop_name, TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY 
       sale_month, ct.crop_name;



CREATE OR REPLACE VIEW Plant_Bed_Utilization AS
SELECT 
       g.location AS greenhouse_location,
       pb.plant_bed_id,
       ct.crop_name,
       pb.capacity,
       pb.planted_quantity,
       ROUND((pb.planted_quantity / pb.capacity) * 100, 2) AS utilization_percentage,
       '[' || RPAD('=', ROUND((pb.planted_quantity / pb.capacity) * 10), '=') || 
       LPAD('>', CASE WHEN ROUND((pb.planted_quantity / pb.capacity) * 10) < 10 THEN 1 ELSE 0 END, ' ') || 
       RPAD(' ', 10 - ROUND((pb.planted_quantity / pb.capacity) * 10), ' ') || ']' AS progress_bar
FROM 
       Greenhouses g
JOIN 
       Plant_Beds pb ON g.greenhouse_id = pb.greenhouse_id
JOIN 
       Crop_Types ct ON pb.crop_type_id = ct.crop_type_id
ORDER BY 
       greenhouse_location, pb.plant_bed_id;
       
-- View: Crop Sales Summary
CREATE OR REPLACE VIEW Crop_Sales_Summary AS
SELECT 
       ct.crop_name,
       SUM(pb.planted_quantity) AS total_planted_quantity,
       SUM(hc.quantity_kg) AS total_harvested_kg,
       SUM(oi.quantity_kg) AS total_sold_kg,
       ROUND(SUM(oi.quantity_kg * ct.price_per_100g * 10), 2) AS total_revenue_generated
FROM 
       hydro_admin.Crop_Types ct
JOIN 
       hydro_admin.Plant_Beds pb ON ct.crop_type_id = pb.crop_type_id
JOIN 
       hydro_admin.Harvested_Crops hc ON pb.crop_type_id = hc.crop_type_id
JOIN 
       hydro_admin.Order_Items oi ON hc.harvest_id = oi.harvest_id
GROUP BY 
       ct.crop_name
ORDER BY 
       total_revenue_generated DESC;


CREATE OR REPLACE VIEW Greenhouse_Growth_Env_Summary AS
SELECT 
    g.location AS greenhouse_location,
    ct.crop_name,
    pb.plant_bed_id,
    pb.capacity,
    pb.planted_quantity,
    ROUND((pb.planted_quantity / pb.capacity) * 100, 2) AS utilization_percentage,
    gc.stage AS current_growth_stage,
    ROUND(AVG(CASE WHEN s.sensor_type = 'Temperature' THEN sl.reading_value END), 2) AS Sensor1_avg_temp,
    ROUND(AVG(CASE WHEN s.sensor_type = 'Humidity' THEN sl.reading_value END), 2) AS Sensor1_avg_humidity
FROM 
    hydro_admin.Greenhouses g
JOIN 
    hydro_admin.Plant_Beds pb ON g.greenhouse_id = pb.greenhouse_id
JOIN 
    hydro_admin.Crop_Types ct ON pb.crop_type_id = ct.crop_type_id
JOIN 
    hydro_admin.Growth_Cycle gc ON pb.growth_cycle_id = gc.growth_cycle_id
LEFT JOIN 
    hydro_admin.Sensors s ON pb.plant_bed_id = s.plant_bed_id
LEFT JOIN 
    hydro_admin.Sensor_Logs sl ON s.sensor_id = sl.sensor_id
GROUP BY 
    g.location, ct.crop_name, pb.plant_bed_id, pb.capacity, pb.planted_quantity, gc.stage
ORDER BY 
    g.location, pb.plant_bed_id;




--Report with Greenhouse, Plants, and Beds
--Purpose: Displays details about greenhouses, their plant beds, and crop planting to analyze utilization and crop distribution.
SELECT 
    g.greenhouse_id AS greenhouse_id,
    g.location AS greenhouse_location,
    g.total_slots AS total_slots_in_greenhouse,
    pb.plant_bed_id AS plant_bed_id,
    pb.slot_code AS plant_bed_slot_code,
    pb.capacity AS plant_bed_capacity,
    pb.planted_quantity AS planted_quantity_in_bed,
    ct.crop_type_id AS crop_type_id,
    ct.crop_name AS crop_name,
    ct.growing_conditions AS crop_growing_conditions,
    gc.stage AS growth_cycle_stage,
    gc.start_date AS growth_cycle_start_date,
    gc.end_date AS growth_cycle_end_date
FROM 
    GREENHOUSES g
JOIN 
    PLANT_BEDS pb ON g.greenhouse_id = pb.greenhouse_id
LEFT JOIN 
    CROP_TYPES ct ON pb.crop_type_id = ct.crop_type_id
LEFT JOIN 
    GROWTH_CYCLE gc ON pb.growth_cycle_id = gc.growth_cycle_id
ORDER BY 
    g.greenhouse_id, pb.plant_bed_id;
