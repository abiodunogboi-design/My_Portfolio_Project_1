OG Enterprise Ltd — 2025 Sales Performance & Analytics PipelineAn end-to-end data analytics project demonstrating data transformation, database engineering, and executive dashboard design. This project takes messy, unstructured retail transaction logs through a strict SQL data-cleansing pipeline and transforms them into an interactive sales leaderboard for stakeholders.🔗 Live Interactive Dashboard👉 Interact with the Live Tableau Dashboard Here https://public.tableau.com/views/Book2_17839386565120/OGEnterprisesalesleaderboard?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

Project Overview
OG Enterprise Ltd is a multi-category retailer selling Electronics, Furniture, Food, and Fashion items across major regional hubs (Lagos, Abuja, etc.). This project addresses a common business problem: converting inconsistent, raw transactional data into clean, production-grade databases to drive executive sales performance strategies.The project is split into two primary layers:Data Engineering Layer (MySQL): A 7-phase data architecture staging, cleaning, standardizing, casting, and deduplicating raw records.Business Intelligence Layer (Tableau): A sleek executive leaderboard tracking high-level KPIs, staff performance, and customer satisfaction metrics.📊 Executive Dashboard PreviewFigure 1.1: OG Enterprise Ltd Sales Leaderboard UI showcasing core business health metrics.Key High-Level Visualized KPIs:Total Revenue Generated: $31,027,595Total Transaction Volumes: 12,316 RecordsTotal Units Displaced: 44,124 Quantities SoldTop Performing Representatives: Chioma ($5.29M) and Mary ($5.29M) leading the organization's baseline.🛠️ Tech Stack UsedDatabase Engine: MySQL ServerBI Tooling: Tableau Public / Tableau DesktopDocumentation & Version Control: Markdown / Git & GitHub💾 Database Architecture & Data Cleaning PipelineThe raw dataset was intentionally ingested completely as unstructured VARCHAR definitions to prevent data loss, character truncation, or unexpected format rejections during early staging.Below is the structured 7-phase pipeline executed inside MySQL to engineer the final analytics-ready layer:Phase 1 & 2: Environment Setup & ProfilingRaw ingestion structure setup and preliminary field profiling to isolate text anomalies, case styling errors, and formatting inconsistencies:

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

.Phase 3 & 4: Staging Isolation & Text StandardizationCreated an isolated staging space to protect raw data integrity. Handled empty strings (''), standardized regional casing errors (e.g., transforming LAGOS and ABUJA entries into clean proper casing), and handled null items safely:sql-- Standardizing text fields and handling blanks
UPDATE my_portfolio_project_1_staging SET city = 'Unknown location' WHERE city = '';
UPDATE my_portfolio_project_1_staging SET city = 'Lagos' WHERE city = 'LAGOS';
UPDATE my_portfolio_project_1_staging SET city = 'Abuja' WHERE city = 'ABUJA';
UPDATE my_portfolio_project_1_staging SET product_category = 'Other' WHERE product_category = '';
Use code with caution.Phase 5: Safe Data Type Conversions & CastingTransformed arbitrary text fields into computational structures (INT, DECIMAL, DATE) to support aggregations and time-series logic:sql-- Upgrading columns into mathematical definitions
UPDATE my_portfolio_project_1_staging SET order_date = STR_TO_DATE(NULLIF(TRIM(order_date), ''), '%Y-%m-%d');
ALTER TABLE my_portfolio_project_1_staging MODIFY COLUMN order_date DATE;

UPDATE my_portfolio_project_1_staging SET revenue = CAST(NULLIF(TRIM(revenue), '') AS DECIMAL(10,2));
ALTER TABLE my_portfolio_project_1_staging MODIFY revenue DECIMAL(10,2);
Use code with caution.Phase 6: Feature Engineering & EnrichmentDerived descriptive columns to enhance analysis, such as categorizing quantitative feedback scores into descriptive performance buckets:sql-- Creating descriptive business classifications
ALTER TABLE my_portfolio_project_1_staging ADD COLUMN rating_grade VARCHAR(20);
UPDATE my_portfolio_project_1_staging SET rating_grade = CASE 
    WHEN customer_rating = 5 THEN 'Excellent'
    WHEN customer_rating = 4 THEN 'Good'
    WHEN customer_rating = 3 THEN 'Average'
    WHEN customer_rating = 2 THEN 'Fair'
    WHEN customer_rating = 1 THEN 'Poor'
    ELSE 'No Rating' END;
Use code with caution.Phase 7: Deduplication & Final Schema CommitIdentified exact-match redundant duplicates through windowed partitioning (ROW_NUMBER()), committed clean records into a production-grade destination, and optimized database performance:sqlCREATE TABLE my_portfolio_project_1_clean LIKE my_portfolio_project_1_staging;
INSERT INTO my_portfolio_project_1_clean SELECT DISTINCT * FROM my_portfolio_project_1_staging;
DROP TABLE my_portfolio_project_1_staging;
RENAME TABLE my_portfolio_project_1_clean TO my_portfolio_project_1_staging;
Use code with caution.📈 Core Business Insights DerivedSales Representative Parity: The leaderboard shows a highly competitive sales floor. The top two representatives, Chioma and Mary, are separated by less than $10,000 in total generated revenue.Velocity Trends: Representatives average between 5.5 to 5.8 orders per day, maintaining tight operational efficiency across the board.Customer Satisfaction Warning: Despite high sales volumes, the average customer satisfaction score hovers between 2.46 and 2.54 out of 5. This indicates a critical post-purchase friction point (e.g., delivery delays or product quality variations) that requires operational review.
