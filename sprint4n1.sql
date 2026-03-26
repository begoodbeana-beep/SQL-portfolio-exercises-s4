CREATE DATABASE IF NOT EXISTS bootcamp_db;
use bootcamp_db;
CREATE TABLE dim_users (
    user_id     INT PRIMARY KEY,
    name        VARCHAR(100),
    surname     VARCHAR(100),
    phone       VARCHAR(50),
    email       VARCHAR(150),
    birth_date  VARCHAR(50),
    country     VARCHAR(100),
    city        VARCHAR(100),
    postal_code VARCHAR(20),
    address     VARCHAR(255)
);
CREATE TABLE dim_credit_cards (
    card_id       VARCHAR(20) PRIMARY KEY,
    user_id       INT,
    iban          VARCHAR(50),
    pan           VARCHAR(50),
    pin           INT,
    cvv           INT,
    track1        VARCHAR(255),
    track2        VARCHAR(255),
    expiring_date VARCHAR(10)
);
CREATE TABLE dim_companies (
    company_id   VARCHAR(20) PRIMARY KEY,
    company_name VARCHAR(150),
    phone        VARCHAR(50),
    email        VARCHAR(150),
    country      VARCHAR(100),
    website      VARCHAR(255)
    );
CREATE TABLE dim_products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(150),
    price        DECIMAL(10,2),
    colour       VARCHAR(20),
    weight       DECIMAL(5,2),
    warehouse_id VARCHAR(20)
);
CREATE TABLE fact_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    card_id        VARCHAR(20),
    business_id    VARCHAR(20),
    timestamp      DATETIME,
    amount         DECIMAL(10,2),
    declined       TINYINT(1),
    user_id        INT
);
CREATE TABLE transaction_products (
    transaction_id VARCHAR(50),
    product_id     INT,
    PRIMARY KEY (transaction_id, product_id)
);
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv'
INTO TABLE dim_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, name, surname, phone, email, birth_date, country, city, postal_code, address);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv'
INTO TABLE dim_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(user_id, name, surname, phone, email, birth_date, country, city, postal_code, address);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE dim_credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(card_id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE dim_companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company_id, company_name, phone, email, country, website);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, price, colour, weight, warehouse_id);

ALTER TABLE dim_products ADD COLUMN price_temp VARCHAR(20);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, price_temp, colour, weight, warehouse_id);

SET SQL_SAFE_UPDATES = 0;

UPDATE dim_products
SET price = CAST(REPLACE(price_temp, '$', '') AS DECIMAL(10,2));

SET SQL_SAFE_UPDATES = 1;

UPDATE dim_products
SET price = CAST(REPLACE(price_temp, '$', '') AS DECIMAL(10,2));

ALTER TABLE dim_products DROP COLUMN price_temp;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE fact_transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transaction_id, card_id, business_id, timestamp, amount, declined, @products, user_id, @lat, @lon);

CREATE TABLE temp_transactions (
    transaction_id VARCHAR(50),
    product_ids    VARCHAR(255)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE temp_transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @card, @biz, @ts, @amt, @dec, product_ids, @uid, @lat, @lon)
SET transaction_id = @id;

INSERT INTO transaction_products (transaction_id, product_id)
SELECT 
    transaction_id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', n.n), ',', -1)) AS product_id
FROM temp_transactions
JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
) n ON CHAR_LENGTH(product_ids) - CHAR_LENGTH(REPLACE(product_ids, ',', '')) >= n.n - 1
WHERE TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(product_ids, ',', n.n), ',', -1)) != '';

DROP TABLE temp_transactions;

SELECT 'dim_users'            AS tabela, COUNT(*) AS registros FROM dim_users
UNION ALL
SELECT 'dim_credit_cards',      COUNT(*) FROM dim_credit_cards
UNION ALL
SELECT 'dim_companies',         COUNT(*) FROM dim_companies
UNION ALL
SELECT 'dim_products',          COUNT(*) FROM dim_products
UNION ALL
SELECT 'fact_transactions',     COUNT(*) FROM fact_transactions
UNION ALL
SELECT 'transaction_products',  COUNT(*) FROM transaction_products;

ALTER TABLE fact_transactions
ADD CONSTRAINT fk_fact_user
FOREIGN KEY (user_id) REFERENCES dim_users(user_id);

ALTER TABLE fact_transactions
ADD CONSTRAINT fk_fact_card
FOREIGN KEY (card_id) REFERENCES dim_credit_cards(card_id);

ALTER TABLE fact_transactions
ADD CONSTRAINT fk_fact_company
FOREIGN KEY (business_id) REFERENCES dim_companies(company_id);

ALTER TABLE transaction_products
ADD CONSTRAINT fk_trans_prod_transaction
FOREIGN KEY (transaction_id) REFERENCES fact_transactions(transaction_id);

ALTER TABLE transaction_products
ADD CONSTRAINT fk_trans_prod_product
FOREIGN KEY (product_id) REFERENCES dim_products(product_id);