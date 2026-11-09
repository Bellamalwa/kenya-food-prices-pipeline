# Makefile
.PHONY: pipeline
pipeline:
	docker compose up -d
	@sleep 5
	@echo "Running cleaning..."
	docker compose exec -T db psql -U foodprices_user -d kenya_food_prices < transform/01_clean.sql
	@echo "Running transformations..."
	docker compose exec -T db psql -U foodprices_user -d kenya_food_prices < transform/02_aggregate.sql
	@echo "Exporting..."
	python3 serve/export_summary.py
	@echo "Done."

.PHONY: test
test:
	docker compose exec -T db psql -U foodprices_user -d kenya_food_prices < tests/test_pipeline.sql
	@echo "All tests passed"