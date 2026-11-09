-- tests/test_pipeline.sql
-- These assertions FAIL if the pipeline is broken.
-- Run after every pipeline execution.

-- Test 1: Source data exists
DO $$
BEGIN
  ASSERT (SELECT COUNT(*) FROM food_prices) > 0,
    'food_prices is empty — source load failed';
END $$;

-- Test 2: Clean table has expected rows
DO $$
BEGIN
 ASSERT (SELECT COUNT(*) FROM clean_food_prices) > 9000,
    'clean_food_prices has fewer than 9K rows';
END $$;

-- Test 3: All clean rows are retail aggregate
DO $$
BEGIN
  ASSERT NOT EXISTS (
    SELECT 1 FROM clean_food_prices
    WHERE pricetype != 'Retail' OR priceflag != 'aggregate'
  ), 'clean_food_prices contains non-retail or non-aggregate rows';
END $$;

-- Test 4: No NULL prices in clean table
DO $$
BEGIN
  ASSERT NOT EXISTS (
    SELECT 1 FROM clean_food_prices WHERE price IS NULL
  ), 'clean_food_prices contains NULL prices';
END $$;

-- Test 5: Quarterly trends are complete for analysis commodities
DO $$
BEGIN
  ASSERT (
    SELECT COUNT(DISTINCT commodity) 
    FROM quarterly_trends
    WHERE quarter >= '2021-01-01'
  ) >= 4, 'quarterly_trends is missing commodities';
END $$;
\echo 'Test 6: volatility table populated'
DO $$
BEGIN
  ASSERT (
    SELECT COUNT(*) FROM commodity_volatility
    WHERE cv_pct_full IS NOT NULL AND cv_pct_full > 0
  ) = 4, 'commodity_volatility should have 4 rows with positive CV';
END $$;

\echo 'All tests passed'
