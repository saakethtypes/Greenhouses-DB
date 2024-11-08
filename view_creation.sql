-- View: Customer Purchase History (with price included, no harvest date or harvested quantity)
CREATE OR REPLACE VIEW hydro_admin.Customer_Purchase_History AS
SELECT 
       c.customer_id, 
       c.first_name, 
       c.last_name, 
       ct.crop_name, 
       oi.quantity_kg AS purchased_quantity,
       o.order_date,
       ct.price_per_100g AS price_per_100g
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
ORDER BY 
       c.customer_id, o.order_date;


-- View: Monthly Sales by Crop (total_revenue with $ sign at the end)
CREATE OR REPLACE VIEW Monthly_Sales_By_Crop AS
SELECT 
       ct.crop_name, 
       TO_CHAR(o.order_date, 'YYYY-MM') AS sale_month,
       SUM(oi.quantity_kg) AS total_quantity_sold,
       TO_CHAR(ROUND(SUM(oi.quantity_kg * ct.price_per_100g / 100), 2), '99999.99') || ' $' AS total_revenue
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


-- View: Average Sensor Readings Per Bed (both humidity and temperature for each plant bed)
CREATE OR REPLACE VIEW Avg_Sensor_Readings_Per_Bed AS
SELECT 
       pb.plant_bed_id,
       s.sensor_type,
       ROUND(AVG(sl.reading_value), 2) AS avg_reading
FROM 
       Sensors s
JOIN 
       Sensor_Logs sl ON s.sensor_id = sl.sensor_id
JOIN 
       Plant_Beds pb ON s.plant_bed_id = pb.plant_bed_id
GROUP BY 
       pb.plant_bed_id, s.sensor_type
ORDER BY 
       pb.plant_bed_id, s.sensor_type;


-- View: Plant Bed Utilization (with visual progress bar for percentage)
CREATE OR REPLACE VIEW Plant_Bed_Utilization AS
SELECT 
       g.location AS greenhouse_location,
       pb.plant_bed_id,
       ct.crop_name,
       pb.capacity,
       pb.planted_quantity,
       ROUND((pb.planted_quantity / pb.capacity) * 100, 2) AS utilization_percentage,
       RPAD('[' || RPAD('=', ROUND((pb.planted_quantity / pb.capacity) * 10, 0), '=') || '>', 10, ' ') || ']', 12) AS progress_bar
FROM 
       Greenhouses g
JOIN 
       Plant_Beds pb ON g.greenhouse_id = pb.greenhouse_id
JOIN 
       Crop_Types ct ON pb.crop_type_id = ct.crop_type_id
ORDER BY 
       greenhouse_location, pb.plant_bed_id;
