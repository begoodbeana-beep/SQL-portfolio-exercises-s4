use bootcamp_db;
CREATE TEMPORARY TABLE card_status AS
SELECT
    c.card_id,
    CASE
        WHEN MIN(f.declined) = 1 AND COUNT(f.transaction_id) >= 3 THEN 'Inactive'
        ELSE 'Active'
    END AS status
FROM dim_credit_cards c
LEFT JOIN fact_transactions f
    ON c.card_id = f.card_id
GROUP BY c.card_id;

SELECT COUNT(*) AS active_cards
FROM card_status
WHERE status = 'Active';