--From what I understand, here you want to find the minimum "created_at" date for each vendor
--and filter every vendor from the bookings table with that date larger than the "day_key"
--therefore I would approach it this way

--Find the minimum date per id
WITH Vendor_Bookings AS(
	SELECT
		id AS vendor_id,
		--Check that there are multiple dates per id, otherwise "MIN" is redundant
		--Also check that created_at is not already a date because the conversion would be redundant
		MIN(DATE(created_at)) AS created_at
	FROM `bookings`
	GROUP BY 1
)

--Use an inner join to filter the rows that we want instead of the IN function
--In most cases, especially when the lists are large, "IN" is inefficient
--Also we avoid creating two subqueries for the two separate conditions (id and date)
SELECT
	*
FROM `orders` a
INNER JOIN Vendor_Bookings b
ON a.vendor_id = b.vendor_id
AND a.day_key >= b.created_at
WHERE a.brand = 'EF_GR'
