--------------------------------------------------------------------------------- 
-- PHASE 1: ENVIRONMENT SETUP & RAW DATA IMPORT
-------------------------------------------------------------------------------
-- Intentional use of VARCHAR for all columns to prevent data loss or import truncation due to raw data inconsistencies.
CREATE TABLE my_portfolio_project_1(
 order_id VARCHAR(50),
 customer_name VARCHAR(50),
 email VARCHAR(50),
 city VARCHAR(50),
 product_category VARCHAR(50),
 order_date VARCHAR(50),
 quantity VARCHAR(50),
 unit_price VARCHAR(50),
 discount_pct VARCHAR(50),
 revenue VARCHAR(50),
 customer_age VARCHAR(50),
 customer_rating VARCHAR(50),
 sales_rep VARCHAR(50),
 payment_method VARCHAR(50)
 );
 
-------------------------------------------------------------------------------
-- PHASE 2: INITIAL DATA INSPECTION
-------------------------------------------------------------------------------
-- Profiling categorical fields and identifying blank values or text casing anomalies.

SELECT * FROM my_portfolio_project_1
	LIMIT 10;
SELECT DISTINCT city FROM my_portfolio_project_1;
SELECT DISTINCT product_category FROM my_portfolio_project_1;
SELECT DISTINCT sales_rep FROM my_portfolio_project_1;
SELECT DISTINCT product_category FROM my_portfolio_project_1;
SELECT DISTINCT customer_rating FROM my_portfolio_project_1;
SELECT DISTINCT discount_pct FROM my_portfolio_project_1;
-------------------------------------------------------------------------------
-- PHASE 3: CREATING A STAGING ENVIRONMENT
-------------------------------------------------------------------------------
-- Isolating data cleaning operations to a staging table to protect the raw source data.

CREATE TABLE my_portfolio_project_1_STAGING
	LIKE my_portfolio_project_1;

INSERT my_portfolio_project_1_staging
	SELECT * FROM my_portfolio_project_1; 
SELECT * FROM my_portfolio_project_1_staging;

-------------------------------------------------------------------------------
-- PHASE 4: TEXT STANDARDIZATION & MISSING VALUE HANDLING
-------------------------------------------------------------------------------
-- Correcting empty strings, standardized casing, and assigning defaults for missing categorical fields.

SET SQL_SAFE_UPDATES = 0;
SELECT order_id, 
	CAST(NULLIF(TRIM(order_id), '') AS SIGNED) 
		FROM my_portfolio_project_1_staging;
UPDATE my_portfolio_project_1_staging
	SET order_id = CAST(NULLIF(TRIM(order_id), '') AS SIGNED);
ALTER TABLE my_portfolio_project_1_staging
	MODIFY COLUMN order_id INT;
DESCRIBE my_portfolio_project_1_staging;

SELECT DISTINCT(city)
	FROM my_portfolio_project_1_staging
		WHERE city ='';
UPDATE my_portfolio_project_1_staging
	SET city = 'Unknown location'
		WHERE city = '';
SELECT DISTINCT city FROM my_portfolio_project_1_staging;
SELECT * FROM my_portfolio_project_1_staging 
	WHERE city = 'Lagos';
UPDATE my_portfolio_project_1_staging
	SET city = 'Lagos'
		WHERE city = 'LAGOS';
UPDATE my_portfolio_project_1_staging
	SET city = 'Abuja'
		WHERE city = 'ABUJA';
SELECT customer_name
	FROM my_portfolio_project_1_staging
		WHERE customer_name='';
UPDATE my_portfolio_project_1_staging
	SET customer_name = NULL 
		WHERE customer_name = '';

SELECT email
	FROM my_portfolio_project_1_staging
		WHERE email='';
UPDATE my_portfolio_project_1_staging
	SET email = NULL 
		WHERE email = '';
SELECT product_category
	FROM my_portfolio_project_1_staging
		WHERE product_category ='';
UPDATE my_portfolio_project_1_staging
	SET product_category= 'Other' 
		WHERE product_category = '';
UPDATE my_portfolio_project_1_staging
	SET order_date = STR_TO_DATE(NULLIF(TRIM(order_date), ''), '%Y-%m-%d');
-------------------------------------------------------------------------------
-- PHASE 5: DATA TYPE CONVERSIONS & CASTING
-------------------------------------------------------------------------------
-- Safely cleaning spaces, converting texts to numeric/date values, and modifying column definitions.

SELECT quantity, 
	CAST(NULLIF(TRIM(quantity), '') AS DECIMAL(10,1)) 
		FROM my_portfolio_project_1_staging;
        
UPDATE my_portfolio_project_1_staging
	SET quantity = CAST(NULLIF(TRIM(quantity), '') AS DECIMAL(10,1));
    
ALTER TABLE my_portfolio_project_1_staging
	MODIFY COLUMN quantity INT;
    
ALTER TABLE my_portfolio_project_1_staging
	MODIFY COLUMN order_date DATE;
    
SELECT revenue
	FROM my_portfolio_project_1_staging
		WHERE revenue ='';

SELECT revenue, 
	CAST(NULLIF(TRIM(revenue), '') AS DECIMAL(10,2)) AS clean_float
		FROM my_portfolio_project_1_staging;
        
UPDATE my_portfolio_project_1_staging
	SET revenue = CAST(NULLIF(TRIM(revenue), '') AS DECIMAL(10,2));
    
ALTER TABLE my_portfolio_project_1_staging
	MODIFY revenue DECIMAL(10,2);

UPDATE my_portfolio_project_1_staging
	SET unit_price = CAST(NULLIF(TRIM(unit_price), '') AS DECIMAL(10,2));

ALTER TABLE my_portfolio_project_1_staging
	MODIFY unit_price DECIMAL(10,2);
    
SELECT DISTINCT(discount_pct) FROM my_portfolio_project_1_staging;

SELECT discount_pct, CAST(NULLIF(TRIM(discount_pct), '') AS SIGNED)
	FROM my_portfolio_project_1_staging;
    
UPDATE my_portfolio_project_1_staging
	SET discount_pct = CAST(NULLIF(TRIM(discount_pct), '') AS SIGNED);
    
ALTER TABLE my_portfolio_project_1_staging
	MODIFY discount_pct INT;
    
UPDATE my_portfolio_project_1_staging
	SET discount_pct = 0 WHERE discount_pct IS NULL;
    
SELECT DISTINCT(customer_age) FROM my_portfolio_project_1_staging;

	UPDATE my_portfolio_project_1_staging
    SET customer_age = NULL WHERE customer_age = '';
    
SELECT customer_age, CAST(NULLIF(TRIM(customer_age), '') AS SIGNED) 
	FROM my_portfolio_project_1_staging;
    
UPDATE my_portfolio_project_1_staging
	SET customer_age = CAST(NULLIF(TRIM(customer_age), '') AS SIGNED);
    
ALTER TABLE my_portfolio_project_1_staging
	MODIFY customer_age INT;
    
SELECT DISTINCT(customer_rating) FROM my_portfolio_project_1_staging;

SELECT customer_rating, CAST(NULLIF(TRIM(customer_rating), '') AS SIGNED) 
	FROM my_portfolio_project_1_staging;
    
UPDATE my_portfolio_project_1_staging
	SET customer_rating = CAST(NULLIF(TRIM(customer_rating), '') AS SIGNED);
    
ALTER TABLE my_portfolio_project_1_staging
	MODIFY customer_rating INT;
-------------------------------------------------------------------------------
-- PHASE 6: DATA ENRICHMENT & FEATURE ENGINEERING
-------------------------------------------------------------------------------
-- Deriving descriptive columns and validating quantitative attributes to add business context.
SELECT customer_rating, 
CASE
	WHEN customer_rating = 5 THEN 'Excellent'
	WHEN customer_rating = 4 THEN 'Good'
	WHEN customer_rating = 3 THEN 'Average'
	WHEN customer_rating = 1 THEN 'Poor'
	ELSE 'No Rating' 
END
AS rating_grade FROM my_portfolio_project_1_staging;

ALTER TABLE my_portfolio_project_1_staging
	ADD COLUMN rating_grade VARCHAR(20);
    
UPDATE my_portfolio_project_1_staging 
SET rating_grade = 
CASE
	WHEN customer_rating = 5 THEN 'Excellent'
	WHEN customer_rating = 4 THEN 'Good'
	WHEN customer_rating = 3 THEN 'Average'
	WHEN customer_rating = 2 THEN 'Fair'
	WHEN customer_rating = 1 THEN 'Poor'
	ELSE 'No Rating' 
END;

SELECT DISTINCT(sales_rep) FROM my_portfolio_project_1_staging;

UPDATE my_portfolio_project_1_staging
	SET sales_rep = 'No Rep' WHERE sales_rep ='';
    
SELECT DISTINCT(payment_method) FROM my_portfolio_project_1_staging;

UPDATE my_portfolio_project_1_staging
	SET payment_method = 'Unspecified' WHERE payment_method = '';
    
SELECT 
	unit_price,
	discount_pct, 
	quantity, 
	revenue, ROUND(revenue/ (unit_price - (unit_price * (discount_pct/100))), 3) AS quantity_updated
FROM my_portfolio_project_1_staging;

ALTER TABLE my_portfolio_project_1_staging
	ADD updated_quantity DECIMAL(10,2);
    
UPDATE my_portfolio_project_1_staging
	SET updated_quantity =  ROUND(revenue/ (unit_price - (unit_price * (discount_pct/100))), 3);

SELECT COUNT(updated_quantity) FROM my_portfolio_project_1_staging 
	WHERE updated_quantity IS NULL;
    
-------------------------------------------------------------------------------
-- PHASE 7: DEDUPLICATION & FINAL TABLE COMMIT
-------------------------------------------------------------------------------
-- Dropping exact-match redundant records and finalizing the primary analytics table.

WITH duplicate_entries AS
(SELECT *, 
ROW_NUMBER()OVER(PARTITION BY 
order_id,
 customer_name,
 email,
 city,
 product_category,
 order_date,
 quantity,
 unit_price,
 discount_pct,
 revenue,
 customer_age,
 customer_rating,
 sales_rep,
 payment_method) AS row_num
 FROM my_portfolio_project_1_staging)
 SELECT * FROM duplicate_entries WHERE row_num > 1;
 
 SELECT * FROM my_portfolio_project_1_staging WHERE email = 'tracirodriguez@example.net';
 SELECT * FROM my_portfolio_project_1_staging WHERE order_id = 3017;

CREATE TABLE my_portfolio_project_1_clean LIKE my_portfolio_project_1_staging;
INSERT INTO my_portfolio_project_1_clean
	SELECT DISTINCT * FROM my_portfolio_project_1_staging;
DROP TABLE my_portfolio_project_1_staging;
RENAME TABLE my_portfolio_project_1_clean TO my_portfolio_project_1_staging;
SELECT * FROM my_portfolio_project_1_staging;