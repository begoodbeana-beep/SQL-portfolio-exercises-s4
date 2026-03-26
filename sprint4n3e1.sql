use bootcamp_db;
SELECT 
    p.product_id, 
    p.product_name, 
    COUNT(tp.transaction_id) AS times_sold
FROM dim_products p
JOIN transaction_products tp 
    ON p.product_id = tp.product_id
GROUP BY p.product_id, p.product_name
ORDER BY times_sold DESC;