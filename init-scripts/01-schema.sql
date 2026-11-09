-- Table for market data
CREATE TABLE IF NOT EXISTS markets (
    market_id     INTEGER PRIMARY KEY,
    market        TEXT NOT NULL,
    countryiso3   TEXT,
    admin1        TEXT,
    admin2        TEXT,
    latitude      NUMERIC(9,6),
    longitude     NUMERIC(9,6)
);

-- Table for food price data
CREATE TABLE IF NOT EXISTS food_prices (
    date            DATE,
    admin1          TEXT,
    admin2          TEXT,
    market          TEXT,
    market_id       INTEGER,
    latitude        NUMERIC(9,6),
    longitude       NUMERIC(9,6),
    category        TEXT,
    commodity       TEXT,
    commodity_id    INTEGER,
    unit            TEXT,
    priceflag       TEXT,
    pricetype       TEXT,
    currency        TEXT,
    price           NUMERIC(12,2),
    usdprice        NUMERIC(12,4)
);

CREATE INDEX IF NOT EXISTS idx_food_prices_date ON food_prices(date);
CREATE INDEX IF NOT EXISTS idx_food_prices_market_id ON food_prices(market_id);