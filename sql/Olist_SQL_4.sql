SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state
FROM olist_analysis.olist_orders_dataset AS o
LEFT JOIN olist_analysis.olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
LIMIT 10;
SELECT
    COUNT(*) AS total_joined_rows,
    COUNT(DISTINCT o.order_id) AS unique_orders,
    SUM(
        CASE
            WHEN c.customer_id IS NULL THEN 1
            ELSE 0
        END
    ) AS unmatched_orders
FROM olist_analysis.olist_orders_dataset AS o
LEFT JOIN olist_analysis.olist_customers_dataset AS c
    ON o.customer_id = c.customer_id;
    SELECT
    COUNT(*) AS delivered_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage

FROM olist_analysis.olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
  WITH review_per_order AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM olist_analysis.olist_reviews_full
    GROUP BY order_id
)
SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(*) AS total_orders,

    ROUND(AVG(r.avg_review_score), 2) AS average_review

FROM olist_analysis.olist_orders_dataset AS o

LEFT JOIN review_per_order AS r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_status;
SELECT
    c.customer_state,

    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_percentage

FROM olist_analysis.olist_orders_dataset AS o

JOIN olist_analysis.olist_customers_dataset AS c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY late_percentage DESC;
SELECT
    COUNT(*) AS late_orders,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                HOUR,
                order_estimated_delivery_date,
                order_delivered_customer_date
            )
        ) / 24.0,
        2
    ) AS avg_delay_days,

    MAX(
        TIMESTAMPDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        )
    ) AS max_delay_days

FROM olist_analysis.olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date >
      order_estimated_delivery_date;
      SELECT
    DATE_FORMAT(
        order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,

    COUNT(*) AS delivered_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_percentage

FROM olist_analysis.olist_orders_dataset

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY order_month
ORDER BY order_month;
SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(*) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS product_sales_value,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_order_item_value
FROM olist_analysis.olist_order_items_dataset AS oi
JOIN olist_analysis.olist_orders_dataset AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';
SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    COUNT(*) AS items_sold,

    ROUND(SUM(oi.price), 2) AS sales_value

FROM olist_analysis.olist_order_items_dataset AS oi

JOIN olist_analysis.olist_orders_dataset AS o
    ON oi.order_id = o.order_id

LEFT JOIN olist_analysis.olist_products_dataset AS p
    ON oi.product_id = p.product_id

LEFT JOIN olist_analysis.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name

WHERE o.order_status = 'delivered'

GROUP BY category

ORDER BY sales_value DESC

LIMIT 10;
SELECT
    COUNT(*) AS total_items,
    COUNT(p.product_id) AS matched_items,
    SUM(
        CASE
            WHEN p.product_id IS NULL THEN 1
            ELSE 0
        END
    ) AS unmatched_items
FROM olist_analysis.olist_order_items_dataset AS oi
LEFT JOIN olist_analysis.olist_products_dataset AS p
    ON oi.product_id = p.product_id;
    SELECT
    COUNT(*) AS total_reviews,
    SUM(CASE WHEN r.order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_ids,
    SUM(CASE WHEN o.order_id IS NULL THEN 1 ELSE 0 END) AS unmatched_orders,
    SUM(CASE WHEN r.review_score NOT BETWEEN 1 AND 5
             OR r.review_score IS NULL
        THEN 1 ELSE 0 END) AS invalid_scores
FROM olist_analysis.olist_reviews_full AS r
LEFT JOIN olist_analysis.olist_orders_dataset AS o
    ON r.order_id = o.order_id;