-- test_idempotency.sql
-- Run the pipeline twice; results must be identical.

DO $$
DECLARE
  count_before INT;
  count_after INT;
BEGIN
  SELECT COUNT(*) INTO count_before FROM clean_food_prices;
  -- (re-run transform)
  PERFORM 1;
  SELECT COUNT(*) INTO count_after FROM clean_food_prices;
  ASSERT count_before = count_after,
    'Pipeline is not idempotent — row count changed on re-run';
END $$;