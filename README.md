# DATABASE CREATION

## Objective
This project creates a simplified data warehouse for analyzing users, credit cards, companies, products, and financial transactions.  
The goal is to perform analytical queries using a star schema structure.

## Level 1

### 1 Dimension Tables

**dim_users – Users**  
Contains user information.

**Columns:**  
- user_id (INT, PK)  
- name (VARCHAR)  
- surname (VARCHAR)  
- phone (VARCHAR)  
- email (VARCHAR)  
- birth_date (VARCHAR)  
- country (VARCHAR)  
- city (VARCHAR)  
- postal_code (VARCHAR)  
- address (VARCHAR)  

**dim_credit_cards – Credit Cards**  
Contains credit card details.

**Columns:**  
- card_id (PK)  
- user_id (FK to dim_users)  
- iban (VARCHAR)  
- pan (VARCHAR)  
- pin (INT)  
- cvv (INT)  
- track1 (VARCHAR)  
- track2 (VARCHAR)  
- expiring_date (VARCHAR)  

**dim_companies – Companies**  
Contains information about the companies where transactions occur.

**Columns:**  
- company_id (PK)  
- company_name (VARCHAR)  
- phone (VARCHAR)  
- email (VARCHAR)  
- country (VARCHAR)  
- website (VARCHAR)  

**dim_products – Products**  
Contains information about products sold in transactions.

**Columns:**  
- product_id (PK)  
- product_name (VARCHAR)  
- price (DECIMAL)  
- colour (VARCHAR)  
- weight (DECIMAL)  
- warehouse_id (VARCHAR)  

### 2 Fact Table

**fact_transactions**  
Stores transaction records linking users, cards, and companies.

**Columns:**  
- transaction_id (PK)  
- card_id (FK to dim_credit_cards)  
- business_id (FK to dim_companies)  
- timestamp (TIMESTAMP)  
- amount (DECIMAL)  
- declined (BOOLEAN)  
- user_id (FK to dim_users)  

### 3 Bridge Table

**transaction_products**  
Represents many-to-many relationship between transactions and products.

**Columns:**  
- transaction_id (FK to fact_transactions)  
- product_id (FK to dim_products)  
- Composite PK: (transaction_id, product_id)  

### 4 Foreign Keys for Star Schema - Diagram created and saved in `diagrama4estrelas.png`

- fact_transactions.user_id → dim_users.user_id  
- fact_transactions.card_id → dim_credit_cards.card_id  
- fact_transactions.business_id → dim_companies.company_id  
- transaction_products.transaction_id → fact_transactions.transaction_id  
- transaction_products.product_id → dim_products.product_id  

With these relationships, the star schema is created: **fact_transactions** at the center, four dimension tables around it, and **transaction_products** linking transactions to products.

## Exercises Performed

**Exercise 1 – Users with More Than 80 Transactions**  
Queries created and saved in `sprint4n1e1.sql`

```sql
SELECT u.user_id, u.name AS user_name, t.total_transactions
FROM dim_users u
JOIN (
    SELECT user_id, COUNT(*) AS total_transactions
    FROM fact_transactions
    GROUP BY user_id
    HAVING COUNT(*) > 80
) t ON u.user_id = t.user_id
ORDER BY t.total_transactions DESC;
```

Objective: Identify users with more than 80 transactions.
Result: List of top users by transaction count.

Exercise 2 – Users by Total Transaction Value
Queries created and saved in `sprint4n1e2.sql`

```sql
SELECT u.user_id, u.name AS user_name, SUM(f.amount) AS total_value
FROM dim_users u
JOIN fact_transactions f ON u.user_id = f.user_id
GROUP BY u.user_id
ORDER BY total_value DESC
LIMIT 10;
```
Objective: Identify the top 10 users by total amount spent.
Result: List of users with the highest total transaction value.

## LEVEL 2

Create a table that reflects the status of credit cards based on the last three transactions:  
- If the last three transactions were all declined → card is **Inactive**  
- If at least one of the last three transactions was approved → card is **Active**  

**Table Creation - Exercise 1 – Count Active Cards**
Queries created and saved in `sprint4n2e1.sql`

```sql
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
```
Result: 5000 active cards

## LEVEL 3
Create a table that allows us to connect products.csv data with the existing database, using product_ids from transactions. Then, determine how many times each product was sold.

**Exercise 1 – Count Product Sales**
Queries created and saved in `sprint4n3e1.sql` and diagram in `diagramanewproducts`

* Tables Used
- dim_products – contains all product information
- transaction_products – bridge table linking transactions to products

```sql
SELECT
    p.product_id,
    p.product_name,
    COUNT(tp.transaction_id) AS times_sold
FROM dim_products p
LEFT JOIN transaction_products tp
    ON p.product_id = tp.product_id
GROUP BY p.product_id, p.product_name
ORDER BY times_sold DESC;
```
Result: Table showing each product and the number of times it was sold


