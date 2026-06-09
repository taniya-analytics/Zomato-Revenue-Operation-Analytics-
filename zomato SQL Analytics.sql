CREATE DATABASE zomato_analytics;

USE zomato_analytics;

SELECT * FROM users LIMIT 5;

SELECT * FROM orders LIMIT 5;

SELECT * FROM restaurant LIMIT 5;

SELECT * FROM food LIMIT 5;

SELECT * FROM menu_clean LIMIT 5;

SELECT * FROM delivery_operations LIMIT 5;

DESCRIBE users;
DESCRIBE orders;
DESCRIBE restaurant;
DESCRIBE menu_clean;
DESCRIBE food;
DESCRIBE delivery_operations;

-- Basic KPI Analysis
-- Total Customers

SELECT COUNT(*) AS total_customers
FROM users;

-- Total Restaurants
SELECT COUNT(*) AS total_restaurants
FROM restaurant;

-- Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Total Food Items
SELECT COUNT(*) AS total_food_items
FROM food;

-- CUSTOMER ANALYTICS
-- Top 10 Customers by Order Count

SELECT
    user_id,
    COUNT(*) AS total_orders
FROM orders
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;


-- Orders by Gender

SELECT
    u.gender,
    COUNT(*) AS total_orders
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
GROUP BY u.gender;


-- Orders by Occupation

SELECT
    u.occupation,
    COUNT(*) AS total_orders
FROM users u
JOIN orders o
    ON u.user_id = o.user_id
GROUP BY u.occupation
ORDER BY total_orders DESC;


-- Customers by Marital Status

SELECT
    `Marital Status`,
    COUNT(*) AS total_customers
FROM users
GROUP BY `Marital Status`;


-- Customer Age Group Analysis

SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '45+'
    END AS age_group,
    COUNT(*) AS customer_count
FROM users
GROUP BY age_group;

--  RESTAURANT ANALYTICS
-- Top 10 Restaurants by Orders

SELECT
    r.name,
    COUNT(*) AS total_orders
FROM restaurant r
JOIN orders o
    ON r.id = o.r_id
GROUP BY r.name
ORDER BY total_orders DESC
LIMIT 10;


-- Highest Rated Restaurants

SELECT
    name,
    rating
FROM restaurant
ORDER BY rating DESC
LIMIT 10;


-- Average Cost by City

SELECT
    city,
    ROUND(AVG(cost),2) AS avg_cost
FROM restaurant
GROUP BY city
ORDER BY avg_cost DESC;


-- Top Cuisines

SELECT
    cuisine,
    COUNT(*) AS total_restaurants
FROM restaurant
GROUP BY cuisine
ORDER BY total_restaurants DESC;


-- Rating Distribution

SELECT
    rating,
    COUNT(*) AS restaurant_count
FROM restaurant
GROUP BY rating
ORDER BY rating DESC;

-- FOOD ANALYTICS
-- Total Food Items
SELECT COUNT(*) AS total_food_items
FROM food;

-- Veg vs Non-Veg Distribution
SELECT
    veg_or_non_veg,
    COUNT(*) AS total_items
FROM food
GROUP BY veg_or_non_veg
ORDER BY total_items DESC;

--  Most Frequently Appearing Food Items
SELECT
    f.item,
    COUNT(*) AS total_occurrences
FROM food f
JOIN menu_clean m
    ON f.f_id = m.f_id
GROUP BY f.item
ORDER BY total_occurrences DESC
LIMIT 20;

-- Average Food Price
SELECT
    ROUND(AVG(price),2) AS avg_food_price
FROM menu_clean;

--  MOST EXPENSIVE FOOD ITEMS
SELECT
    f.item,
    m.price
FROM food f
JOIN menu_clean m
    ON f.f_id = m.f_id
ORDER BY m.price DESC
LIMIT 20;

-- CHEAPEST FOOD ITEMS
SELECT
    f.item,
    m.price
FROM food f
JOIN menu_clean m
    ON f.f_id = m.f_id
ORDER BY m.price ASC
LIMIT 20;

-- AVERAGE PRICE BY FOOD TYPE
SELECT
    f.veg_or_non_veg,
    ROUND(AVG(m.price),2) AS avg_price
FROM food f
JOIN menu_clean m
    ON f.f_id = m.f_id
GROUP BY f.veg_or_non_veg;

-- TOP REVENUE POTENTIAL FOOD ITEMS
SELECT
    f.item,
    COUNT(*) AS menu_count,
    ROUND(AVG(m.price),2) AS avg_price,
    ROUND(COUNT(*) * AVG(m.price),2) AS revenue_potential
FROM food f
JOIN menu_clean m
    ON f.f_id = m.f_id
GROUP BY f.item
ORDER BY revenue_potential DESC
LIMIT 20;

-- CUISINE WISE AVERAGE PRICE
SELECT
    cuisine,
    ROUND(AVG(price),2) AS avg_price
FROM menu_clean
GROUP BY cuisine
ORDER BY avg_price DESC;

-- TOP CUISINES BY NUMBER OF MENU ITEMS
SELECT
    cuisine,
    COUNT(*) AS total_items
FROM menu_clean
GROUP BY cuisine
ORDER BY total_items DESC;

-- FOOD ITEM RANKING USING WINDOW FUNCTION

SELECT
    item,
    total_occurrences,
    RANK() OVER(
        ORDER BY total_occurrences DESC
    ) AS food_rank
FROM
(
    SELECT
        f.item,
        COUNT(*) AS total_occurrences
    FROM food f
    JOIN menu_clean m
        ON f.f_id = m.f_id
    GROUP BY f.item
) ranked_food;


-- TOP 5 MOST EXPENSIVE FOOD ITEMS

SELECT *
FROM
(
    SELECT
        f.item,
        m.price,
        ROW_NUMBER() OVER(
            ORDER BY m.price DESC
        ) AS row_num
    FROM food f
    JOIN menu_clean m
        ON f.f_id = m.f_id
) expensive_food
WHERE row_num <= 5;

-- TOP 10 MOST EXPENSIVE CUISINES
SELECT
    cuisine,
    MAX(price) AS highest_price
FROM menu_clean
GROUP BY cuisine
ORDER BY highest_price DESC
LIMIT 10;

-- PRICE RANGE ANALYSIS
SELECT
    CASE
        WHEN price < 100 THEN 'Below 100'
        WHEN price BETWEEN 100 AND 250 THEN '100-250'
        WHEN price BETWEEN 251 AND 500 THEN '251-500'
        ELSE 'Above 500'
    END AS price_range,
    COUNT(*) AS total_items
FROM menu_clean
GROUP BY price_range
ORDER BY total_items DESC;

-- VEG/NON-VEG REVENUE POTENTIAL
SELECT
    f.veg_or_non_veg,
    ROUND(SUM(m.price),2) AS total_price_value
FROM food f
JOIN menu_clean m
    ON f.f_id = m.f_id
GROUP BY f.veg_or_non_veg
ORDER BY total_price_value DESC;

-- INDEX CREATION FOR PERFORMANCE

CREATE INDEX idx_food_fid
ON food(f_id(50));

CREATE INDEX idx_menu_clean_fid
ON menu_clean(f_id(50));


-- DELIVERY OPERATIONS ANALYTICS
-- Total Deliveries
SELECT COUNT(*) AS total_deliveries
FROM delivery_operations;


-- Average Delivery Time
SELECT ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time
FROM delivery_operations;

-- Delivery Time by City
SELECT
    City,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time
FROM delivery_operations
GROUP BY City
ORDER BY avg_delivery_time DESC;

-- Weather Impact
SELECT
    Weather_conditions,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time
FROM delivery_operations
GROUP BY Weather_conditions
ORDER BY avg_delivery_time DESC;

-- Traffic Impact
SELECT
    Road_traffic_density,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time
FROM delivery_operations
GROUP BY Road_traffic_density
ORDER BY avg_delivery_time DESC;

-- Vehicle Performance
SELECT
    Type_of_vehicle,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time
FROM delivery_operations
GROUP BY Type_of_vehicle
ORDER BY avg_delivery_time;

-- Festival vs Non-Festival
SELECT
    Festival,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time,
    COUNT(*) AS total_orders
FROM delivery_operations
GROUP BY Festival;

-- Order Type Analysis 
SELECT
    Type_of_order,
    COUNT(*) AS total_orders,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time
FROM delivery_operations
GROUP BY Type_of_order
ORDER BY total_orders DESC;

-- Peak Order Hours
SELECT
    HOUR(Time_Orderd) AS order_hour,
    COUNT(*) AS total_orders
FROM delivery_operations
GROUP BY order_hour
ORDER BY total_orders DESC;

-- City Ranking
SELECT
    City,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_delivery_time,
    RANK() OVER(
        ORDER BY AVG(`Time_taken (min)`)
    ) AS city_rank
FROM delivery_operations
GROUP BY City;

-- ADVANCED SQL
-- Customer Ranking
SELECT
    user_id,
    COUNT(*) AS total_orders,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS customer_rank
FROM orders
GROUP BY user_id;

-- Restaurant Rating Ranking
SELECT
    name,
    rating,
    DENSE_RANK() OVER (
        ORDER BY rating DESC
    ) AS rating_rank
FROM restaurant;

-- Monthly Order Trend
SELECT
    MONTH(order_date) AS month_no,
    COUNT(*) AS total_orders
FROM orders
GROUP BY MONTH(order_date)
ORDER BY month_no;

-- Top 5 Restaurants in Each City
SELECT *
FROM (
    SELECT
        city,
        name,
        rating,
        ROW_NUMBER() OVER(
            PARTITION BY city
            ORDER BY rating DESC
        ) AS rn
    FROM restaurant
) x
WHERE rn <= 5;

-- Average Delivery Time by Traffic Level Ranking
SELECT
    Road_traffic_density,
    ROUND(AVG(`Time_taken (min)`),2) AS avg_time,
    RANK() OVER(
        ORDER BY AVG(`Time_taken (min)`) DESC
    ) AS traffic_rank
FROM delivery_operations
GROUP BY Road_traffic_density;

