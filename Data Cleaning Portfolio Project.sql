-- Create a table with columns from Nashville Housing file

CREATE TABLE nashville_housing (
	unique_id SERIAL PRIMARY KEY,
	parcel_id VARCHAR(20) UNIQUE,
	land_use VARCHAR(50),
	property_address VARCHAR(200),
	sale_date DATE,
	sale_price BIGINT,
	legal_reference VARCHAR(50),
	sold_as_vacant VARCHAR (10),
	owner_name VARCHAR(200),
	owner_address VARCHAR(200),
	acreage DOUBLE PRECISION,
	tax_district VARCHAR(50),
	land_value BIGINT,
	building_value BIGINT,
	total_value BIGINT,
	year_built BIGINT,
	bedrooms INTEGER,
	full_bath INTEGER,
	half_bath INTEGER
)


-- Alter the table by dropping the constraint in parcel id

ALTER TABLE
	nashville_housing
DROP CONSTRAINT
	nashville_housing_parcel_id_key
	
-- Successfully imported the csv file after fixing the errors
-- Errors included sale price data type and constraint in parcel id
-- Removed the constraint UNIQUE 


/*

Cleaning Data in SQL Queries

*/

SELECT
	*
FROM
	nashville_housing
	
----------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT
	sale_date
FROM
	nashville_housing
	
-- When I manually created the columns, the data type that I used for sale_date is DATE
-- I didn't have to standardize the date format


----------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT
	*
FROM
	nashville_housing
--WHERE
	--property_address IS NULL
ORDER BY 
	parcel_id



SELECT
	a.parcel_id,
	a.property_address,
	b.parcel_id,
	b.property_address,
	COALESCE(a.property_address,b.property_address)
FROM
	nashville_housing a
JOIN
	nashville_housing b ON a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
WHERE
	a.property_address IS NULL
	
	
UPDATE
	nashville_housing a
SET
	property_address = COALESCE(a.property_address,b.property_address)
FROM
	nashville_housing b
WHERE
	a.parcel_id = b.parcel_id
	AND a.unique_id <> b.unique_id
	AND a.property_address IS NULL



----------------------------------------------------------------------------------------

-- Breaking Out Address Into Individual Columns (Address, City, State)

SELECT
	property_address
FROM
	nashville_housing
--WHERE
	--property_address IS NULL
--ORDER BY 
	--parcel_id


-- Here, we split the property_address based on where the comma is
SELECT
SUBSTRING 
	(property_address,1,POSITION(',' IN property_address) -1) AS address,
	SUBSTRING
		(property_address,POSITION(',' IN property_address) +1,LENGTH(property_address)) AS address
FROM
	nashville_housing


-- We then create two columns, one for the part before the comma and one for after the comma
ALTER TABLE
	nashville_housing
ADD
	property_split_address VARCHAR(255)
	
UPDATE
	nashville_housing
SET
	property_split_address = SUBSTRING(property_address,1,POSITION(',' IN property_address) -1)


ALTER TABLE
	nashville_housing
ADD
	property_split_city VARCHAR(255)

UPDATE
	nashville_housing
SET
	property_split_city = SUBSTRING(property_address,POSITION(',' IN property_address) +1,LENGTH(property_address))



-- We check if we have successfully added the two new columns called property_split_address and property_split_city
SELECT
	*
FROM
	nashville_housing





-- Let's try splitting the address, city, and state by using a different approach
SELECT
	owner_address
FROM
	nashville_housing


SELECT
	SPLIT_PART(REPLACE(owner_address, ',', '.'), '.', 1),
	SPLIT_PART(REPLACE(owner_address, ',', '.'), '.', 2),
	SPLIT_PART(REPLACE(owner_address, ',', '.'), '.', 3)
FROM
	nashville_housing





ALTER TABLE
	nashville_housing
ADD
	owner_split_address VARCHAR(255)
	
UPDATE
	nashville_housing
SET
	owner_split_address = SPLIT_PART(REPLACE(owner_address, ',', '.'), '.', 1)


ALTER TABLE
	nashville_housing
ADD
	owner_split_city VARCHAR(255)

UPDATE
	nashville_housing
SET
	owner_split_city = SPLIT_PART(REPLACE(owner_address, ',', '.'), '.', 2)


ALTER TABLE
	nashville_housing
ADD
	owner_split_state VARCHAR(255)

UPDATE
	nashville_housing
SET
	owner_split_state = SPLIT_PART(REPLACE(owner_address, ',', '.'), '.', 3)
	
	
-- We check if we have successfully split the address, city, and state
SELECT
	*
FROM
	nashville_housing
	
	

----------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT
	(sold_as_vacant),
	COUNT(sold_as_vacant)
FROM
	nashville_housing
GROUP BY
	sold_as_vacant
ORDER BY
	COUNT(sold_as_vacant)
	
	

SELECT
	sold_as_vacant,
	CASE 
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
		WHEN sold_as_vacant = 'N' THEN 'No'
		ELSE sold_as_vacant
	END
FROM
	nashville_housing



UPDATE
	nashville_housing
SET
	sold_as_vacant = CASE 
		WHEN sold_as_vacant = 'Y' THEN 'Yes'
		WHEN sold_as_vacant = 'N' THEN 'No'
		ELSE sold_as_vacant
	END



----------------------------------------------------------------------------------------

-- Remove Duplicates

WITH row_num_CTE AS (
SELECT
	*,
	ROW_NUMBER() OVER (
		PARTITION BY
			parcel_id,
			property_address,
		  	sale_price,
		 	sale_date,
			legal_reference
		ORDER BY 
			unique_id
	) AS row_num
FROM
	nashville_housing
--ORDER BY
	--parcel_id
)
-- I had to format it in a different way for the DELETE FROM section because of the number of columns included
DELETE FROM nashville_housing
WHERE (parcel_id, property_address, sale_price, sale_date, legal_reference, unique_id) IN (
	SELECT parcel_id, property_address, sale_price, sale_date, legal_reference, unique_id
	FROM (
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY parcel_id, property_address, sale_price, sale_date, legal_reference
				ORDER BY unique_id
			) AS row_num
		FROM nashville_housing
	) AS subquery
	WHERE row_num > 1
)
--ORDER BY
	--property_address




----------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT
	*
FROM
	nashville_housing
	
	
ALTER TABLE
	nashville_housing
DROP COLUMN
	owner_address

ALTER TABLE
	nashville_housing
DROP COLUMN
	tax_district

ALTER TABLE
	nashville_housing
DROP COLUMN
	property_address
	
ALTER TABLE
	nashville_housing
DROP COLUMN
	sale_date

	
	





















