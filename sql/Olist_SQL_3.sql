CREATE TABLE IF NOT EXISTS olist_analysis.product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);
LOAD DATA LOCAL INFILE
'/path/to/olist-dataset/product_category_name_translation.csv'
INTO TABLE olist_analysis.product_category_name_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_category_name, product_category_name_english);
SELECT COUNT(*) AS total_categories
FROM olist_analysis.product_category_name_translation;