-- First, let's check which tables exist
SELECT table_name 
FROM user_tables
WHERE table_name IN ('CROP_TYPES', 'PLANT_BEDS', 'GROWTH_CYCLE', 'ORDERS', 
                    'HARVESTED_CROPS', 'SENSOR_LOGS', 'ORDER_ITEMS');

-- 1. Basic Crop Information View
CREATE OR REPLACE VIEW VW_CROP_INFO AS
SELECT 
    crop_name,
    harvest_time_days,
    price_per_100g as base_price,
    growing_conditions,
    crop_type_id
FROM 
    CROP_TYPES
WHERE 
    crop_name IN ('Premium Lettuce', 'Cherry Tomatoes', 'English Cucumber', 
                  'Fresh Basil', 'Baby Spinach', 'Bell Peppers')
ORDER BY 
    harvest_time_days;

-- 2. Plant Bed Allocation View
CREATE OR REPLACE VIEW VW_CROP_PLANTINGS AS
SELECT 
    ct.crop_name,
    COUNT(pb.plant_bed_id) as total_plant_beds,
    SUM(pb.planted_quantity) as total_planted,
    SUM(pb.capacity) as total_capacity,
    ROUND(AVG(pb.planted_quantity / pb.capacity) * 100, 2) as avg_utilization_pct
FROM 
    CROP_TYPES ct
    LEFT JOIN PLANT_BEDS pb ON ct.crop_type_id = pb.crop_type_id
WHERE 
    ct.crop_name IN ('Premium Lettuce', 'Cherry Tomatoes', 'English Cucumber', 
                     'Fresh Basil', 'Baby Spinach', 'Bell Peppers')
GROUP BY 
    ct.crop_name
ORDER BY 
    total_planted DESC NULLS LAST;

-- 3. Production Analysis View
CREATE OR REPLACE VIEW VW_CROP_PRODUCTION AS
SELECT 
    ct.crop_name,
    COUNT(hc.harvest_id) as total_harvests,
    ROUND(SUM(hc.quantity_kg), 2) as total_quantity_harvested,
    ROUND(SUM(hc.available_quantity_kg), 2) as total_quantity_available,
    ROUND(AVG(hc.quantity_kg), 2) as avg_harvest_size_kg
FROM 
    CROP_TYPES ct
    LEFT JOIN HARVESTED_CROPS hc ON ct.crop_type_id = hc.crop_type_id
WHERE 
    ct.crop_name IN ('Premium Lettuce', 'Cherry Tomatoes', 'English Cucumber', 
                     'Fresh Basil', 'Baby Spinach', 'Bell Peppers')
GROUP BY 
    ct.crop_name
ORDER BY 
    total_quantity_harvested DESC NULLS LAST;

-- 4. Crop Value Analysis View
CREATE OR REPLACE VIEW VW_CROP_VALUE_ANALYSIS AS
SELECT 
    ct.crop_name,
    ct.price_per_100g,
    ROUND(SUM(hc.quantity_kg * 10 * ct.price_per_100g), 2) as potential_revenue,
    ROUND(SUM(hc.available_quantity_kg * 10 * ct.price_per_100g), 2) as available_inventory_value
FROM 
    CROP_TYPES ct
    LEFT JOIN HARVESTED_CROPS hc ON ct.crop_type_id = hc.crop_type_id
WHERE 
    ct.crop_name IN ('Premium Lettuce', 'Cherry Tomatoes', 'English Cucumber', 
                     'Fresh Basil', 'Baby Spinach', 'Bell Peppers')
GROUP BY 
    ct.crop_name, ct.price_per_100g
ORDER BY 
    potential_revenue DESC NULLS LAST;

-- 5. Crop Growth Efficiency View
CREATE OR REPLACE VIEW VW_CROP_EFFICIENCY AS
SELECT 
    ct.crop_name,
    ct.harvest_time_days as expected_growth_days,
    COUNT(pb.plant_bed_id) as active_plant_beds,
    SUM(pb.planted_quantity) as total_plants,
    ROUND(SUM(pb.planted_quantity) / NULLIF(COUNT(pb.plant_bed_id), 0), 2) as avg_plants_per_bed,
    ROUND(SUM(pb.planted_quantity) / NULLIF(SUM(pb.capacity), 0) * 100, 2) as space_utilization_pct
FROM 
    CROP_TYPES ct
    LEFT JOIN PLANT_BEDS pb ON ct.crop_type_id = pb.crop_type_id
WHERE 
    ct.crop_name IN ('Premium Lettuce', 'Cherry Tomatoes', 'English Cucumber', 
                     'Fresh Basil', 'Baby Spinach', 'Bell Peppers')
GROUP BY 
    ct.crop_name, ct.harvest_time_days
ORDER BY 
    space_utilization_pct DESC NULLS LAST;
