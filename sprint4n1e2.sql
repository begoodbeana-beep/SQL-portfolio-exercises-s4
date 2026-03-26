use bootcamp_db;
SELECT 
    u.name AS user_name,
    c.iban,
    AVG(f.amount) AS avg_amount
FROM fact_transactions f
JOIN dim_credit_cards c 
    ON f.card_id = c.card_id
JOIN dim_users u
    ON c.user_id = u.user_id
JOIN dim_companies comp
    ON f.business_id = comp.company_id
WHERE comp.company_name = 'Donec Ltd'
GROUP BY u.name, c.iban
ORDER BY avg_amount DESC;