-- 1. Crop Performance Analysis View
-- This view analyzes crop growth cycles, success rates, and yield efficiency
CREATE OR REPLACE VIEW VW_CROP_PERFORMANCE_ANALYSIS AS
SELECT 
    ct.crop_name,
    ct.harvest_time_days,
    COUNT(DISTINCT gc.growth_cycle_id) as total_cycles,
    ROUND(AVG(hc.quantity_kg), 2) as avg_yield_per_cycle,
    ROUND(SUM(hc.quantity_kg), 2) as total_yield_kg,
    ROUND(AVG(CASE 
        WHEN gc.stage = 'Harvest' THEN 
            (gc.end_date - gc.start_date)
        ELSE NULL 
    END), 1) as actual_avg_days_to_harvest,
    ROUND(AVG(hc.quantity_kg / pb.planted_quantity) * 100, 2) as yield_efficiency_pct,
    ROUND(AVG(sl.reading_value), 2) as avg_optimal_temperature
FROM 
    CROP_TYPES ct
    LEFT JOIN GROWTH_CYCLE gc ON ct.crop_type_id = gc.crop_type_id
    LEFT JOIN HARVESTED_CROPS hc ON gc.growth_cycle_id = hc.growth_cycle_id
    LEFT JOIN PLANT_BEDS pb ON gc.plant_bed_id = pb.plant_bed_id
    LEFT JOIN SENSORS s ON pb.plant_bed_id = s.plant_bed_id AND s.sensor_type = 'TEMPERATURE'
    LEFT JOIN SENSOR_LOGS sl ON s.sensor_id = sl.sensor_id
GROUP BY 
    ct.crop_name, ct.harvest_time_days
ORDER BY 
    total_yield_kg DESC;

-- 2. Greenhouse Operational Efficiency View
-- This view provides insights into greenhouse utilization and environmental control
CREATE OR REPLACE VIEW VW_GREENHOUSE_EFFICIENCY AS
SELECT 
    g.greenhouse_id,
    g.location,
    COUNT(pb.plant_bed_id) as total_plant_beds,
    SUM(pb.capacity) as total_capacity,
    SUM(pb.planted_quantity) as total_planted,
    ROUND((SUM(pb.planted_quantity) / SUM(pb.capacity)) * 100, 2) as utilization_rate,
    COUNT(DISTINCT s.sensor_id) as total_sensors,
    ROUND(AVG(CASE WHEN s.sensor_type = 'TEMPERATURE' THEN sl.reading_value END), 2) as avg_temperature,
    ROUND(AVG(CASE WHEN s.sensor_type = 'HUMIDITY' THEN sl.reading_value END), 2) as avg_humidity,
    ROUND(AVG(CASE WHEN s.sensor_type = 'PH' THEN sl.reading_value END), 2) as avg_ph
FROM 
    GREENHOUSES g
    LEFT JOIN PLANT_BEDS pb ON g.greenhouse_id = pb.greenhouse_id
    LEFT JOIN SENSORS s ON pb.plant_bed_id = s.plant_bed_id
    LEFT JOIN SENSOR_LOGS sl ON s.sensor_id = sl.sensor_id
GROUP BY 
    g.greenhouse_id, g.location;

-- 3. Customer Order Analytics View
-- This view analyzes ordering patterns and customer segmentation
CREATE OR REPLACE VIEW VW_CUSTOMER_ORDER_ANALYTICS AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(oi.order_item_id) as total_items_ordered,
    ROUND(SUM(o.total_amount), 2) as total_spent,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    ROUND(SUM(oi.quantity_kg), 2) as total_kg_purchased,
    CASE 
        WHEN UPPER(c.last_name) LIKE '%WHOLESALE%' THEN 'Wholesale'
        ELSE 'Retail'
    END as customer_type,
    COUNT(DISTINCT ct.crop_type_id) as unique_crops_ordered,
    MAX(o.order_date) as last_order_date
FROM 
    CUSTOMERS c
    LEFT JOIN ORDERS o ON c.customer_id = o.customer_id
    LEFT JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
    LEFT JOIN HARVESTED_CROPS hc ON oi.harvest_id = hc.harvest_id
    LEFT JOIN CROP_TYPES ct ON hc.crop_type_id = ct.crop_type_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
ORDER BY 
    total_spent DESC;

-- 4. Environmental Control and Crop Health View
-- This view correlates sensor data with crop health and growth stages
CREATE OR REPLACE VIEW VW_ENVIRONMENTAL_MONITORING AS
SELECT 
    pb.plant_bed_id,
    ct.crop_name,
    gc.stage as growth_stage,
    ROUND(AVG(CASE WHEN s.sensor_type = 'TEMPERATURE' THEN sl.reading_value END), 2) as avg_temperature,
    ROUND(MIN(CASE WHEN s.sensor_type = 'TEMPERATURE' THEN sl.reading_value END), 2) as min_temperature,
    ROUND(MAX(CASE WHEN s.sensor_type = 'TEMPERATURE' THEN sl.reading_value END), 2) as max_temperature,
    ROUND(AVG(CASE WHEN s.sensor_type = 'HUMIDITY' THEN sl.reading_value END), 2) as avg_humidity,
    ROUND(AVG(CASE WHEN s.sensor_type = 'PH' THEN sl.reading_value END), 2) as avg_ph,
    COUNT(DISTINCT sl.log_id) as total_readings,
    MAX(sl.timestamp) as last_reading_time
FROM 
    PLANT_BEDS pb
    JOIN CROP_TYPES ct ON pb.crop_type_id = ct.crop_type_id
    JOIN GROWTH_CYCLE gc ON pb.growth_cycle_id = gc.growth_cycle_id
    JOIN SENSORS s ON pb.plant_bed_id = s.plant_bed_id
    JOIN SENSOR_LOGS sl ON s.sensor_id = sl.sensor_id
GROUP BY 
    pb.plant_bed_id, ct.crop_name, gc.stage
ORDER BY 
    pb.plant_bed_id;

-- 5. Revenue and Production Trend Analysis View
-- This view analyzes daily revenue, production, and demand patterns
CREATE OR REPLACE VIEW VW_REVENUE_PRODUCTION_TRENDS AS
SELECT 
    o.order_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    ROUND(SUM(o.total_amount), 2) as daily_revenue,
    ROUND(SUM(oi.quantity_kg), 2) as total_kg_sold,
    COUNT(DISTINCT hc.harvest_id) as harvests_utilized,
    ROUND(SUM(hc.quantity_kg), 2) as total_kg_harvested,
    ROUND(SUM(hc.available_quantity_kg), 2) as remaining_inventory_kg,
    COUNT(DISTINCT gc.growth_cycle_id) as active_growth_cycles,
    COUNT(DISTINCT CASE WHEN gc.stage = 'Harvest' THEN gc.growth_cycle_id END) as completed_cycles
FROM 
    ORDERS o
    LEFT JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
    LEFT JOIN HARVESTED_CROPS hc ON oi.harvest_id = hc.harvest_id
    LEFT JOIN GROWTH_CYCLE gc ON hc.growth_cycle_id = gc.growth_cycle_id
GROUP BY 
    o.order_date
ORDER BY 
    o.order_date;
