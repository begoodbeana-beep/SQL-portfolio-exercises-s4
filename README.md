# DATABASE CREATION

## 1. Objective
This project creates a simplified data warehouse for analyzing users, credit cards, companies, products, and financial transactions.  
The goal is to perform analytical queries using a star schema structure.

## 2. Table Structure

### 2.1 Dimension Tables

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

### 2.2 Fact Table

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

### 2.3 Bridge Table

**transaction_products**  
Represents many-to-many relationship between transactions and products.

**Columns:**  
- transaction_id (FK to fact_transactions)  
- product_id (FK to dim_products)  
- Composite PK: (transaction_id, product_id)  

## 3. Foreign Keys for Star Schema - Diagram created and saved in `diagrama4estrelas.png`

- fact_transactions.user_id → dim_users.user_id  
- fact_transactions.card_id → dim_credit_cards.card_id  
- fact_transactions.business_id → dim_companies.company_id  
- transaction_products.transaction_id → fact_transactions.transaction_id  
- transaction_products.product_id → dim_products.product_id  

With these relationships, the star schema is created: **fact_transactions** at the center, four dimension tables around it, and **transaction_products** linking transactions to products.

## 4. Exercises Performed

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
