![Test pipeline](https://github.com/Bellamalwa/kenya-food-prices-pipeline/actions/workflows/test.yml/badge.svg)

Kenya Food Prices Pipeline

Is my food getting more expensive? This project takes 20 years of retail food price records from Kenyan markets and turns them into a database anyone can query — so that question can be answered month after month, not just once.

It's built for households budgeting for staples and for food security analysts tracking affordability.

Technically: a reproducible batch data pipeline that loads World Food Programme (WFP) retail food price data for Kenya into PostgreSQL and produces analysis-ready trend and volatility tables. The repository also contains a research paper (paper/paper.md) analyzing four staple commodities (maize, dry beans, rice, sugar) from 2021 to 2026.

What this does NOT do

Cannot predict prices
Covers only the commodities and markets recorded by WFP
Uses WFP aggregate market-level prices, not individual transaction prices
Cannot yet refresh with new data without rebuilding the database (see below)
Prerequisites

Docker Desktop (or Docker Engine + Compose plugin)
Python 3.11+
Free port 5432 on your local machine
Setup

bash
git clone https://github.com/Bellamalwa/kenya-food-prices-pipeline.git
cd kenya-food-prices-pipeline

cp .env.example .env
# Edit .env and set POSTGRES_PASSWORD to any value

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

make pipeline
Verify it worked

bash
docker compose exec db psql -U foodprices_user -d kenya_food_prices \
  -c "SELECT COUNT(*) FROM food_prices;"
Expected: 29298 rows.

If you see 0, the seed didn't run. Check:

bash
docker compose logs db | grep -i error
Refreshing with new data

The pipeline is re-runnable: running make pipeline rebuilds all derived tables from the current raw data. But adding new WFP data currently requires rebuilding the database, because the seed scripts run only on first boot:

bash
docker compose down -v   # wipes the volume
make pipeline            # re-runs init scripts on an empty volume
Incremental data refresh — adding new rows without wiping — is on the roadmap.

Pipeline architecture

The pipeline runs in four stages, orchestrated by make pipeline:

Ingestion — Raw WFP CSVs are loaded into food_prices via init-scripts/ on first container startup.
Cleaning — transform/01_clean.sql filters to retail aggregate prices, excludes non-food items, and produces clean_food_prices.
Transformation — transform/02_aggregate.sql builds two analysis tables: quarterly_trends (per-commodity quarterly averages) and commodity_volatility (coefficient of variation per commodity, full period and shock-excluded).
Serving — serve/export_summary.py exports both tables to timestamped CSVs in output/.
Running the pipeline

bash
./run_pipeline.sh   # all stages, with per-run logging

# Or run stages individually
make pipeline       # clean → aggregate → export
make test           # run data quality assertions
make clean          # remove generated output/
Outputs:

output/quarterly_trends_YYYY-MM-DD.csv
output/commodity_volatility_YYYY-MM-DD.csv
logs/pipeline_YYYYMMDD_HHMMSS.log
Reliability

What is true today:

Cleaning and transformation are idempotent — they use DROP + CREATE, so re-running produces identical results with no duplicate rows. Ingestion is not idempotent — seed scripts run once on first boot.
Tested — make test runs 6 data quality assertions (row volume, filter correctness, null checks, table population).
Freshness-tracked — every derived table carries a loaded_at timestamp.
Logged — ./run_pipeline.sh writes per-run logs to logs/.
Can be scheduled — ops/crontab.example provides a template for daily execution; installing it is a manual step.
Project structure

text
.
├── docker-compose.yml              # Postgres service
├── Makefile                        # pipeline / test / clean targets
├── run_pipeline.sh                 # pipeline wrapper with logging
├── requirements.txt                # Python dependencies
├── LICENSE                         # MIT (code)
├── .env.example                    # Environment template
├── init-scripts/
│   ├── 01-schema.sql               # Table definitions (runs once)
│   └── 02-seed.sql                 # CSV loader (runs once)
├── transform/
│   ├── 01_clean.sql                # Creates clean_food_prices
│   └── 02_aggregate.sql            # Creates analysis tables
├── serve/
│   └── export_summary.py           # Exports tables to CSV
├── tests/
│   └── test_pipeline.sql           # 6 data quality assertions
├── ops/
│   └── crontab.example             # Scheduling template
├── data/raw/                       # Source CSVs from WFP
├── paper/
│   ├── paper.md                    # Research paper
│   ├── make_figures.py             # Figure generation script
│   ├── figure1_trends.png
│   └── figure2_volatility.png
├── output/                         # Generated CSVs (gitignored)
├── logs/                           # Pipeline logs (gitignored)
├── README.md
├── RESEARCH_NOTES.md               # Methodology and findings
└── DATA_NOTES.md                   # Data profiling observations
Note: init-scripts/ only runs on the first container startup, when the pgdata volume is empty. To re-run them, use docker compose down -v.

Data source

Provider: World Food Programme (WFP) — VAM Food Prices
Dataset: Kenya food prices (WFP Food Prices for Kenya)
Source: HDX
Files dated: 2026-11-08 (verify with ls -la data/raw/)
Coverage: January 2006 – October 2026 (about 20 years)
Currency: KES (Kenyan Shilling)
Analysis period: 2021-01-01 to 2026-10-15 (pre-2021 excluded due to a change in WFP's data collection regime)
Research findings

The paper (paper/paper.md) analyzes retail prices for four staple commodities (maize, dry beans, rice, sugar) from 2021 to 2026. Two findings:

A shared 2023–2024 price shock. All four commodities peaked within three consecutive quarters (Q3 2023 – Q1 2024), rising 67–99% above 2021 baselines. Prices partially unwound by 2026, ending 25–39% above baseline.
Two volatility regimes. Over the full period, all staples showed similar volatility (CV 23–26%). Excluding the crisis window, the ordering changes materially: dry beans fall to the least volatile position (19.16%), while maize rises to near the top (21.12%), effectively tied with sugar (21.30%).
See RESEARCH_NOTES.md for the full methodology log.

Roadmap

Done:

✅ Postgres + Docker Compose setup
✅ Schema and initial data load
✅ Data profiling (units, categories, priceflag, structural breaks)
✅ Cleaning and transformation scripts
✅ Serving (CSV exports)
✅ Data quality tests
✅ Logging and freshness tracking
✅ Research paper with findings
Next:
**If `make pipeline` fails at the Exporting step with `Connection refused` or `port is already allocated`:** another Postgres may be running on port 5432. Stop it (`docker compose down` in the other project) or free the port (`sudo lsof -i :5432`), then run `docker compose down -v && make pipeline`.

🔜 Incremental data refresh (fetch new WFP data, add new rows without rebuilding)
🔜 API layer for dashboards
🔜 Operational monitoring (alerts on pipeline failure)
License

Code: MIT — see LICENSE file.
Data: WFP food prices, published via the Humanitarian Data Exchange. Check the HDX page for the exact data license (WFP food prices are typically published under CC BY-IGO). Any reuse must credit the World Food Programme.
