SELECT COUNT(*) FROM airbnb_nyc.data1;
SELECT * FROM airbnb_nyc.data1;

# Add booked out columns (will help understand how many days the host is booked for 30, 60, 90, 365 days)
# Also add projected revenue columns which is (price * booked out for 30, 60, 90, 365 days columns)
ALTER TABLE data1
ADD COLUMN booked_out_30_days INT,
ADD COLUMN booked_out_60_days INT,
ADD COLUMN booked_out_90_days INT,
ADD COLUMN booked_out_365_days INT,
ADD COLUMN proj_rev_30_days INT,
ADD COLUMN proj_rev_60_days INT,
ADD COLUMN proj_rev_90_days INT,
ADD COLUMN proj_rev_365_days INT;

-- Update the columns with calculated values
SET SQL_SAFE_UPDATES = 0;
UPDATE data1
SET 
    booked_out_30_days = (30 - availability_30),
    booked_out_60_days = (60 - availability_60),
    booked_out_90_days = (90 - availability_90),
    booked_out_365_days = (365 - availability_365),
    proj_rev_30_days = price * (30 - availability_30),
    proj_rev_60_days = price * (60 - availability_60),
    proj_rev_90_days = price * (90 - availability_90),
    proj_rev_365_days = price * (365 - availability_365)
WHERE host_id IS NOT NULL; -- Assuming host_id is a key column
SET SQL_SAFE_UPDATES = 1;

-- Verify that the columns are correct
SELECT host_id, price, 
    booked_out_30_days, booked_out_60_days, booked_out_90_days, booked_out_365_days,
    proj_rev_30_days, proj_rev_60_days, proj_rev_90_days, proj_rev_365_days
FROM data1;


#### Host Analysis: 
-- Calculate the number of days since the host's first listing to understand their experience level
SELECT host_id, host_name,
       DATEDIFF(CURRENT_DATE, host_since) AS days_since_first_listing
FROM data1 
WHERE host_since IS NOT NULL
ORDER BY days_since_first_listing DESC;

-- Performance of Superhosts vs Non-Superhosts
CREATE INDEX idx_booked_out_365_days
ON data1 (booked_out_365_days);

SELECT host_is_superhost, 
       AVG(booked_out_365_days) AS avg_booked_rate,
       AVG(proj_rev_365_days) AS avg_revenue
FROM data1
GROUP BY host_is_superhost
HAVING AVG(proj_rev_365_days) > 0
ORDER BY avg_revenue DESC;

-- Which are the top hosts to generate the most revenue, bookings, and reviews?
SELECT host_id, host_name, num_reviews, total_revenue, total_booked_rate 
FROM (
    SELECT host_id, host_name, 
           COUNT(number_of_reviews) AS num_reviews, 
           SUM(proj_rev_365_days) AS total_revenue, 
           SUM(booked_out_365_days) AS total_booked_rate
    FROM data1
    GROUP BY host_id, host_name
) AS subquery
ORDER BY total_revenue DESC, num_reviews DESC, total_booked_rate DESC
LIMIT 10;

-- Which hosts possibly cancel or do not utilize their listings fully,
-- which could negatively affect the Airbnb platform.
CREATE INDEX idx_availability_365
ON data1 (availability_365);

SELECT host_id, host_name, 
       COUNT(*) AS total_listings, 
       SUM(CASE WHEN availability_365 = 365 THEN 1 ELSE 0 END) AS cancellations
FROM data1
GROUP BY host_id, host_name
HAVING cancellations > 0
ORDER BY cancellations DESC;

-- Classify listings based on positive vs. negative reviews
ALTER TABLE data1 MODIFY COLUMN id BIGINT UNSIGNED;
ALTER TABLE data2 MODIFY COLUMN id BIGINT UNSIGNED;

SELECT host_id, host_name, 
    SUM(CASE WHEN comments LIKE "%bad%" OR comments LIKE "%terrible%" OR comments LIKE "%dirty%" OR comments LIKE "%poor%" THEN 1 ELSE 0 END) AS negative_reviews,
    SUM(CASE WHEN comments LIKE "%amazing%" OR comments LIKE "%perfect%" OR comments LIKE "%clean%" OR comments LIKE "%great%" THEN 1 ELSE 0 END) AS positive_reviews
FROM data2
INNER JOIN data1 ON data2.id = data1.id
GROUP BY host_id, host_name
HAVING positive_reviews > 0 OR negative_reviews > 0
ORDER BY positive_reviews DESC;


#### Seasonality of Bookings: Break down availabilities to analyze how bookings change over time (find monthly trends).

-- Show the number of bookings (based on the number of reviews) for each month. 
-- Assumption that if a review exists for a listing, the property was booked in that month
SELECT 
    EXTRACT(MONTH FROM last_review) AS review_month,
    COUNT(*) AS total_bookings
FROM data1
WHERE last_review IS NOT NULL
GROUP BY review_month
ORDER BY review_month; 

-- Shows the average availability for 30 days, 60 days, 90 days, 365 days across each month
SELECT
    EXTRACT(MONTH FROM last_review) AS review_month,
    AVG(availability_30) AS avg_availability_30,
    AVG(availability_60) AS avg_availability_60,
    AVG(availability_90) AS avg_availability_90,
    AVG(availability_365) AS avg_availability_365
FROM data1
WHERE last_review IS NOT NULL
GROUP BY review_month
ORDER BY review_month;

-- Shows the average price of Airbnbs per month.
SELECT EXTRACT(MONTH FROM last_review) AS review_month, 
       AVG(price) AS avg_price
FROM data1
WHERE last_review IS NOT NULL
GROUP BY review_month
ORDER BY review_month;

-- Shows the average price of Airbnbs per year.
SELECT 
    EXTRACT(YEAR FROM last_review) AS review_year,
    AVG(price) AS avg_price
FROM data1
WHERE last_review IS NOT NULL
GROUP BY review_year
ORDER BY review_year;

-- How has the number of active listings changed over time?
-- (How has the Airbnb platform expanded in terms of listings over the years)
SELECT EXTRACT(YEAR FROM host_since) AS year, 
       COUNT(*) AS num_listings
FROM data1
GROUP BY year
ORDER BY year DESC;

-- Review growth over the years
SELECT EXTRACT(YEAR FROM last_review) AS review_year,
       COUNT(number_of_reviews)
FROM data1
GROUP BY review_year
ORDER BY review_year DESC;

-- Analyze seasonality based on the day of the week. Which day of the week receives the most bookings?
SELECT DAYNAME(last_review) AS review_day, 
       COUNT(*) AS total_bookings
FROM data1
WHERE last_review IS NOT NULL
GROUP BY review_day
ORDER BY FIELD(review_day, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


#### General Analysis: 
-- What is the Price per Bed/Room?
-- Can normalize the price by dividing it by the number of beds or bedrooms to understand value for money.
SELECT neighbourhood, neighbourhood_borough, price, beds, bedrooms,
       CASE WHEN beds > 0 THEN (price / beds) ELSE NULL END AS price_per_bed,
       CASE WHEN bedrooms > 0 THEN (price / bedrooms) ELSE NULL END AS price_per_bedroom
FROM data1;

SELECT AVG(minimum_nights)
FROM data1;

-- Which property types (e.g., apartment, house, etc.) are most popular in different neighborhoods?
SELECT neighbourhood, property_type, COUNT(*) AS total_listings
FROM data1
GROUP BY neighbourhood, property_type
ORDER BY total_listings DESC
LIMIT 10;

-- Which room types generate the most revenue in specific neighborhoods?
SELECT neighbourhood_borough, neighbourhood, room_type, 
       AVG(proj_rev_365_days) AS avg_yearly_revenue
FROM data1
GROUP BY neighbourhood_borough, neighbourhood, room_type
ORDER BY avg_yearly_revenue DESC
LIMIT 10;

-- Check whether certain room types (e.g., entire homes vs. shared rooms) receive better reviews.
SELECT room_type, neighbourhood_borough,
       AVG(review_scores_rating) AS avg_review_score
FROM data1
GROUP BY room_type, neighbourhood_borough
ORDER BY avg_review_score DESC;

-- Which borough is the most profitable?
SELECT neighbourhood_borough, 
       AVG(proj_rev_365_days) AS avg_revenue
FROM data1
GROUP BY neighbourhood_borough
ORDER BY avg_revenue DESC;

-- Filter out the properties with high demand (find by looking for low availability and high booking rates).
SELECT id, host_id, host_name, neighbourhood, 
       price, availability_365, booked_out_365_days
FROM data1
WHERE availability_365 < 50 -- listings that are booked for at least 315 days (365 - 50) in a year (high demand)
ORDER BY booked_out_365_days DESC;

-- Correlation between review scores and price
SELECT AVG(review_scores_rating) AS avg_rating, 
       AVG(price) AS avg_price
FROM data1
GROUP BY EXTRACT(MONTH FROM last_review) 
ORDER BY avg_rating DESC;

-- Identify listings that have very high availability but no bookings, as this could signal properties with low demand or other issues.
SELECT id, host_id, host_name, 
       availability_365, booked_out_365_days
FROM data1
WHERE booked_out_365_days = 0
ORDER BY availability_365 DESC;

-- Average number of bookings based on the host acceptance rate. Percent difference: (241-146)/((241+146)/2)=0.49
WITH acceptance_groups AS (
    SELECT 
        host_id,
        CASE 
            WHEN host_acceptance_rate >= 0.9 THEN 'High'
            ELSE 'Low'
        END AS host_response_rate,
        booked_out_365_days
    FROM data1
)
SELECT 
    host_response_rate,
    AVG(booked_out_365_days) AS avg_booked_out_365
FROM acceptance_groups
GROUP BY host_response_rate;

-- Calculate the percentage of hosts with low review score ratings of 0, 1, and 2
WITH host_counts AS (
    SELECT 
        COUNT(*) AS total_hosts,
        SUM(CASE WHEN review_scores_rating = 0 THEN 1 ELSE 0 END) AS zero_rating_hosts,
        SUM(CASE WHEN review_scores_rating = 1 THEN 1 ELSE 0 END) AS one_rating_hosts,
        SUM(CASE WHEN review_scores_rating = 2 THEN 1 ELSE 0 END) AS two_rating_hosts
    FROM data1
)
SELECT 
    zero_rating_hosts,
    one_rating_hosts,
    two_rating_hosts,
    total_hosts,
    ROUND(((zero_rating_hosts) / total_hosts) * 100.0, 2) AS percentage_zero_rating,
    ROUND(((one_rating_hosts) / total_hosts)  * 100.0, 2) AS percentage_one_rating,
    ROUND(((two_rating_hosts) / total_hosts)  * 100.0, 2) AS percentage_two_rating
FROM host_counts;




