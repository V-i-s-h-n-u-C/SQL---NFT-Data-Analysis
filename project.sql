SELECT * FROM pricedata;

-- 1
SELECT COUNT(*) AS total_sales FROM pricedata;

-- 2
SELECT name, eth_price, usd_price, event_date FROM pricedata
ORDER BY usd_price DESC
LIMIT 5;

-- 3
SELECT event_date, usd_price,
AVG(usd_price) OVER (ORDER BY event_date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_avg_usd_price
FROM (SELECT event_date, usd_price
    FROM pricedata
    ORDER BY event_date
    LIMIT 50
) AS last_50_transactions
ORDER BY event_date;

-- 4
SELECT name, AVG(usd_price) AS average_price
FROM pricedata
GROUP BY name
ORDER BY average_price DESC;

-- 5
SELECT dayofweek(event_date) AS day_of_week,
    COUNT(*) AS sales_count,
    AVG(eth_price) AS avg_eth_price
FROM pricedata
GROUP BY day_of_week
ORDER BY sales_count ASC;

-- 6
SELECT
    CONCAT(
        name, ' was sold for $',
        ROUND(usd_price, -3), ' to ', buyer_address,
        ' from ', seller_address, ' on ',
        event_date
    ) AS summary
FROM pricedata;

-- 7
CREATE VIEW 1919_purchases AS
SELECT *
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

SELECT * FROM 1919_purchases;

-- 8
SELECT
    ROUND(eth_price , -2) AS Bucket,
    COUNT(*) AS count,
    RPAD('', count(*),'*') as histogram
FROM pricedata
GROUP BY Bucket
ORDER BY Bucket;

-- 9
(
    SELECT
        name,
        MAX(usd_price) AS price,
        'highest' AS status
    FROM pricedata
    GROUP BY name

    UNION ALL

    SELECT
        name ,
        MIN(usd_price) AS price,
        'lowest' AS status
    FROM pricedata
    GROUP BY name
)
ORDER BY name, status ASC;

-- 10
WITH max_prices AS (
    SELECT
        date_format(event_date, '%M') AS month,
        YEAR(event_date) AS year,
        name ,
        usd_price AS max_price_usd,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM event_date), EXTRACT(MONTH FROM event_date) ORDER BY usd_price DESC) AS rn
    FROM pricedata
)
SELECT
    month,
    year,
    name,
    max_price_usd
FROM max_prices
WHERE rn = 1
ORDER BY year, month;

-- 11
SELECT
    date_format(event_date, '%Y') AS year,
    date_format(event_date, '%M') AS month,
    ROUND(SUM(usd_price), -2) AS total_volume
FROM pricedata
GROUP BY year,month
ORDER BY year,month;

-- 12
SELECT
    COUNT(*) AS transaction_count
FROM pricedata
WHERE buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

-- 13
CREATE TEMPORARY TABLE daily_avg_prices AS
SELECT
    event_date,
    usd_price,
    AVG(usd_price) OVER (PARTITION BY DATE(event_date)) AS daily_avg_usd_price
FROM pricedata;

SELECT 
    AVG(usd_price) AS estimated_avg_value
FROM daily_avg_prices
WHERE usd_price > (0.9 * daily_avg_usd_price);









