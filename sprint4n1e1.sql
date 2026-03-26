use bootcamp_db;
SELECT 
    u.user_id AS user_id,
    u.name AS user_name,
    t.total_transactions
FROM dim_users u
JOIN (
    SELECT 
        user_id,
        COUNT(*) AS total_transactions
    FROM fact_transactions
    GROUP BY user_id
    HAVING COUNT(*) > 80
) t ON u.user_id = t.user_id
ORDER BY t.total_transactions DESC;