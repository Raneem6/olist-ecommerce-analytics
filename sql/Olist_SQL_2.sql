CREATE TABLE IF NOT EXISTS olist_analysis.olist_sellers_dataset (
    seller_id VARCHAR(32),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);
LOAD DATA LOCAL INFILE
'/path/to/olist-dataset/olist_sellers_dataset.csv'
INTO TABLE olist_analysis.olist_sellers_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(seller_id, seller_zip_code_prefix, seller_city, seller_state);
SELECT COUNT(*) AS total_sellers
FROM olist_analysis.olist_sellers_dataset;