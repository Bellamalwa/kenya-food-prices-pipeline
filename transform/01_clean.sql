-- transform/01_clean.sql
DROP TABLE IF EXISTS clean_food_prices;

CREATE TABLE clean_food_prices AS
SELECT
    date::date                           AS price_date,
    DATE_TRUNC('quarter', date)::date    AS quarter,
    commodity,
    category,
    market_id,
    market,
    admin1                               AS county,
    unit,
    price,
    usdprice,
    pricetype,
    priceflag
FROM food_prices
WHERE pricetype = 'Retail'
  AND priceflag = 'aggregate'
  AND category != 'non-food';

-- Add freshness tracking
ALTER TABLE clean_food_prices ADD COLUMN loaded_at TIMESTAMP NOT NULL DEFAULT NOW();

CREATE INDEX idx_clean_quarter ON clean_food_prices(quarter);
CREATE INDEX idx_clean_commodity ON clean_food_prices(commodity);
CREATE INDEX idx_clean_date ON clean_food_prices(price_date);

COMMENT ON TABLE clean_food_prices IS
  'Cleaned retail aggregate prices, non-food excluded. '
  'Analysis scope: 2021-01-01 to 2026-10-15. '
  'See RESEARCH_NOTES.md for filter rationale.';