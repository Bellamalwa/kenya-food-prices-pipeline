-- transform/02_aggregate.sql

DROP TABLE IF EXISTS quarterly_trends;

CREATE TABLE quarterly_trends AS
SELECT
    quarter,
    commodity,
    unit,
    COUNT(*)                              AS n_records,
    ROUND(AVG(price)::numeric, 2)         AS avg_price,
    ROUND(MIN(price)::numeric, 2)         AS min_price,
    ROUND(MAX(price)::numeric, 2)         AS max_price,
    ROUND(STDDEV(price)::numeric, 2)      AS std_dev
FROM clean_food_prices
WHERE price_date >= '2021-01-01'
  AND commodity IN ('Maize', 'Beans (dry)', 'Rice', 'Sugar')
GROUP BY quarter, commodity, unit;

ALTER TABLE quarterly_trends ADD COLUMN loaded_at TIMESTAMP NOT NULL DEFAULT NOW();

-- Same for volatility table
DROP TABLE IF EXISTS commodity_volatility;

CREATE TABLE commodity_volatility AS
SELECT
    commodity,
    COUNT(*)                                        AS n_records,
    ROUND(AVG(price)::numeric, 2)                   AS mean_price,
    ROUND(STDDEV(price)::numeric, 2)                AS std_dev,
    ROUND((STDDEV(price) / AVG(price))::numeric * 100, 2) AS cv_pct_full,
    ROUND((STDDEV(price) FILTER (WHERE quarter NOT BETWEEN '2023-07-01' AND '2024-06-30') 
           / AVG(price) FILTER (WHERE quarter NOT BETWEEN '2023-07-01' AND '2024-06-30'))::numeric * 100, 2) AS cv_pct_excl_shock
FROM clean_food_prices
WHERE price_date >= '2021-01-01'
  AND commodity IN ('Maize', 'Beans (dry)', 'Rice', 'Sugar')
GROUP BY commodity;

ALTER TABLE commodity_volatility ADD COLUMN loaded_at TIMESTAMP NOT NULL DEFAULT NOW();