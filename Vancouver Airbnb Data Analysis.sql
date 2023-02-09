/* MySQL Vancouver Airbnb Data Analysis */
/* Exploring the publicly available Airbnb dataset to extract interesting insights about the city of Vancouver*/

-- Check first 10 rows
SELECT *
FROM airbnb_vancouver
LIMIT 10;

-- Descriptive analysis of the 'price'
SELECT 
	MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    VAR_POP(price) AS variance,
    STDDEV_POP(price) AS st_dev
FROM airbnb_vancouver;

-- Distribution of listing prices 
SELECT
	CASE WHEN price < 100 THEN 'Less then 100'
		 WHEN price >=100 AND price <200 THEN '100 to 200'
         WHEN price >=200 AND price <300 THEN '200 to 300'
         WHEN price >=300 AND price <400 THEN '300 to 400'
		 WHEN price >=400 AND price <500 THEN '400 to 500'
         WHEN price >=500 AND price <600 THEN '500 to 600'
         WHEN price >=600 AND price <700 THEN '600 to 700'
         WHEN price >=700 AND price <800 THEN '700 to 800'
         WHEN price >=800 AND price <900 THEN '800 to 900'
         ELSE '900 to 1000' END AS price_distribution,
         COUNT(*) AS total_number
FROM airbnb_vancouver
WHERE price <= 1000
GROUP BY price_distribution
ORDER BY price_distribution;

-- Summary statistics about different neighborhoods (neighborhood characteristics)
SELECT 
	neighbourhood,
	COUNT(*) AS no_listings,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    AVG(minimum_nights) AS avg_min_nights,
    AVG(availability_30) AS avg_30day_availability,
    AVG(availability_365) AS avg_365day_availability
FROM airbnb_vancouver
GROUP BY neighbourhood
ORDER BY neighbourhood ASC;

-- Top 10 property types with the most listings, including average price
SELECT
	property_type,
    COUNT(*) AS total_number,
    AVG(price) AS avg_price
FROM airbnb_vancouver
GROUP BY property_type
ORDER BY total_number DESC, avg_price DESC
LIMIT 10;


-- The number of listings and average_price for each room type 
SELECT
	room_type,
    COUNT(*) AS total_number,
    AVG(price) AS avg_price
FROM airbnb_vancouver
GROUP BY room_type
ORDER BY total_number DESC;


/* The number of listings for each number of guests that can be accommodated.
   Only including listings that can accommodate less than 10 guests. */
SELECT 
	accommodates AS number_of_guests,
    COUNT(*) AS total_number
FROM airbnb_vancouver
WHERE accommodates < 10
GROUP BY accommodates
ORDER BY accommodates;

-- The number of listings and average price for each number of bedrooms
SELECT 
	bedrooms,
    COUNT(*) AS total_number,
    AVG(price) AS avg_price
FROM airbnb_vancouver
WHERE bedrooms <= 6
GROUP BY bedrooms
ORDER BY bedrooms;

-- List of all unique neighborhoods in our data set 
SELECT DISTINCT neighbourhood
FROM airbnb_vancouver
ORDER BY neighbourhood;

-- The average price of a data set  VS  average price for each neighborhood
SELECT 
	DISTINCT neighbourhood,
    AVG(price) OVER () AS avg_price,
    AVG(price) OVER (PARTITION BY neighbourhood) AS neighbourhood_avg_price
FROM airbnb_vancouver;


/* 
	The analysis of Airbnb listings in Vancouver shows that there is a variety of property types with apartments and houses being the most popular,
	followed by condominiums and townhouses. 
	Room types were dominated by home/apt, followed by private room and shared room.
	The average price of listings in Vancouver was found to be around $222, with a range of $20 to $3500. 
	The average minimum nights required was 18 nights, and the average availability for the next 30 and 365 days was 7 and 142 days respectively. 
	Neighborhoods also showed variations in terms of the number of listings and average prices. 
	Neighborhoods with the highest average prices are the Downtown area, Kitsilano, West Point Grey, and Arbutus Ridge. 
	The number of listings were dominated by Downtown-area.
*/

    






	