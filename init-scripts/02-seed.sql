\copy markets (market_id, market, countryiso3, admin1, admin2, latitude, longitude) 
FROM '/data/raw/wfp_markets_ken.csv' 
WITH (FORMAT csv, HEADER true);

\copy food_prices (date, admin1, admin2, market, market_id, latitude, longitude, category, commodity, commodity_id, unit, priceflag, pricetype, currency, price, usdprice)
 FROM '/data/raw/wfp_food_prices_ken.csv' 
 WITH (FORMAT csv, HEADER true);