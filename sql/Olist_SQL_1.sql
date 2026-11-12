CREATE TABLE IF NOT EXISTS olist_analysis.olist_products_dataset (
    product_id VARCHAR(32),
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
LOAD DATA LOCAL INFILE
'/path/to/olist-dataset/olist_products_dataset.csv'
INTO TABLE olist_analysis.olist_products_dataset
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, product_category_name,
 @name_len, @desc_len, @photos,
 @weight, @length, @height, @width)
SET
 product_name_lenght = NULLIF(@name_len, ''),
 product_description_lenght = NULLIF(@desc_len, ''),
 product_photos_qty = NULLIF(@photos, ''),
 product_weight_g = NULLIF(@weight, ''),
 product_length_cm = NULLIF(@length, ''),
 product_height_cm = NULLIF(@height, ''),
 product_width_cm = NULLIF(TRIM(TRAILING '\r' FROM @width), '');
 SELECT COUNT(*) AS total_products
FROM olist_analysis.olist_products_dataset;