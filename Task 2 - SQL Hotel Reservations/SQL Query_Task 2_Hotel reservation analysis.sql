              --DATA CLEANING STEP
-- Step 1. Add a temporary column with type DATE.
ALTER TABLE hotel_reservation ADD COLUMN arrival_date_temp DATE;

-- Step 2. Update the temporary column with the converted value of the text column using TO_DATE.
UPDATE hotel_reservation
SET arrival_date_temp = TO_DATE(arrival_date, 'DD-MM-YYYY');

-- Step 3. Verify that the data has been successfully converted and there are no NULL values indicating a failed conversion.
SELECT * FROM hotel_reservation WHERE arrival_date_temp IS NULL;

-- Step 4. If all data has been successfully converted, delete the original text column and rename the column
ALTER TABLE hotel_reservation
DROP COLUMN arrival_date;

ALTER TABLE hotel_reservation
RENAME COLUMN arrival_date_temp TO arrival_date
;

--
SELECT * FROM hotel_reservation WHERE arrival_date IS NULL;


		--TASK ANSWER
SELECT* FROM hotel_reservation;

SELECT
	min(arrival_date) oldest_reservation,
    MAX(arrival_date) newest_reservation
FROM hotel_reservation;

--1. What is the total number of reservations in the dataset?
SELECT
	COUNT(booking_id) numb_of_reservation
FROM hotel_reservation;

--2. Which meal plan is the most popular among guests?
SELECT
	type_of_meal_plan,
    COUNT(type_of_meal_plan)
FROM hotel_reservation
GROUP BY 1
ORDER by 2 DESC;

--3. What is the average price per room for reservations involving children?
SELECT
	ROUND(AVG(avg_price_per_room)::numeric, 2) 
    	AS avg_price_per_room_with_children
FROM hotel_reservation
WHERE no_of_children > 0;

--4. How many reservations were made for the year 20XX (replace XX with the desired year)?
-- reservations were made for the year 2017 and 2018
WITH r_2017 AS (
SELECT
	booking_id reservation_2017
FROM hotel_reservation
WHERE EXTRACT (YEAR FROM arrival_date) = 2017
  ),
r_2018 AS (
SELECT
	booking_id reservation_2018
FROM hotel_reservation
WHERE EXTRACT (YEAR FROM arrival_date) = 2018
  )
SELECT 
	COUNT(reservation_2017) num_reservation_2017,
    COUNT(reservation_2018) num_reservation_2018
from r_2017 
FULL OUTER JOIN r_2018
	ON r_2017.reservation_2017 = r_2018.reservation_2018;

--5. What is the most commonly booked room type?
SELECT
	room_type_reserved,
    COUNT(room_type_reserved) num_room_type_reserved
FROM hotel_reservation
GROUP by 1
ORDER by 2 DESC;

--6. How many reservations fall on a weekend (no_of_weekend_nights > 0)?
SELECT
	COUNT(booking_id) reservations_on_weekend
FROM hotel_reservation
WHERE no_of_weekend_nights > 0;

--7. What is the highest and lowest lead time for reservations?
SELECT
	min(lead_time) lowest_leadtime,
    MAX(lead_time) highest_leadtime
FROM hotel_reservation;

--8. What is the most common market segment type for reservations?
SELECT
	market_segment_type,
    COUNT(market_segment_type) num_market_segment_type
FROM hotel_reservation
GROUP by 1
ORDER by 2 DESC;

--9. How many reservations have a booking status of "Confirmed"?
SELECT
    COUNT(booking_status) confirmed_booking_status
FROM hotel_reservation
WHERE booking_status = 'Not_Canceled';

--10. What is the total number of adults and children across all reservations?
SELECT
	SUM(no_of_adults) total_adults,
    SUM(no_of_children) total_children
FROM hotel_reservation;

--11. What is the average number of weekend nights for reservations involving children?
SELECT
	ROUND(avg(no_of_weekend_nights), 2)
    	AS avg_weekend_nights_with_children
FROM hotel_reservation
WHERE no_of_children > 0;

--12. How many reservations were made in each month of the year?
-- Method 1
SELECT
    TO_CHAR(arrival_date, 'Month') as month_name,
	EXTRACT(MONTH from arrival_date) as month_number,
    EXTRACT(YEAR from arrival_date) as Year,
    COUNT(*) AS total_reservations
FROM hotel_reservation
GROUP BY 1, 2, 3
ORDER BY 3, 2;
-- Method 2 (alternative way)
WITH reservations AS (
    SELECT
        EXTRACT(MONTH FROM arrival_date) AS month_number,
        TO_CHAR(arrival_date, 'Month') AS month,
        EXTRACT(YEAR FROM arrival_date) AS year,
        booking_id
    FROM hotel_reservation
    WHERE EXTRACT(YEAR FROM arrival_date) IN (2017, 2018)
)
SELECT
    month,
    month_number,
    COUNT(CASE WHEN year = 2017 THEN booking_id END) AS total_reservation_2017,
    COUNT(CASE WHEN year = 2018 THEN booking_id END) AS total_reservation_2018
FROM reservations
GROUP BY 1, 2
ORDER BY month_number ASC;

--13. What is the average number of nights (both weekend and weekday) spent by guests for each room type?
SELECT
    room_type_reserved,
    ROUND(AVG(no_of_weekend_nights + no_of_week_nights), 2)
    	AS avg_nights_spent
FROM hotel_reservation
GROUP BY 1
ORDER by 1;

--14. For reservations involving children, what is the most common room type, and
-- what is the average price for that room type?
SELECT
	room_type_reserved,
    count(room_type_reserved) num_of_room_type_reserved,
    ROUND(AVG(avg_price_per_room)::numeric, 2) AS avg_price_per_room
FROM hotel_reservation
WHERE no_of_children > 0
GROUP by 1
order by 1 asc;

--15. Find the market segment type that generates the highest average price per room.
SELECT
	market_segment_type,
    ROUND(avg(avg_price_per_room)::numeric, 2)
    	as avg_price_per_market_segment
FROM hotel_reservation
GROUP by 1
ORDER by 2 DESC;