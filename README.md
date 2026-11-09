# Kenya Food Prices Pipeline

A containerized data pipeline that loads World Food Programme (WFP) food price data for Kenya into PostgreSQL for analysis.

## What it does

Downloads WFP food price CSVs for Kenya and loads them into a PostgreSQL database running in Docker. The pipeline is designed to support analysis of food price trends across Kenyan markets and commodities, and to make those insights accessible for policy and food security work.

**Current status:** 

Data is loaded manually from downloaded CSVs. Automated download is on the roadmap.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine + Compose plugin)
- Free port `5432` on your local machine

## Quickstart

**Clone the repo**
   ```bash
   git clone https://github.com/Bellamalwa/kenya-food-prices-pipeline.git
   cd kenya-food-prices-pipeline
   cp .env.example .env
   docker compose up -d
   ```

### Verify it worked

```bash
docker compose exec db psql -U foodprices_user -d kenya_food_prices \
  -c "SELECT COUNT(*) FROM food_prices;"
```
If you see `0`, the seed didn't run. Check the logs:

```bash
docker compose logs db | grep -i error
```
### Project structure
```text
.
├── docker-compose.yml              # Postgres service definition
├── .env.example                    # Template for environment variables
├── init-scripts/
│   ├── 01-schema.sql               # Table definitions (runs on first boot)
│   └── 02-seed.sql                 # CSV loader (runs on first boot)
├── data/raw/
│   ├── wfp_food_prices_ken.csv     # WFP food prices (29,298 rows)
│   └── wfp_markets_ken.csv         # WFP market metadata (280 rows)
└── DATA_NOTES.md                   # Data profiling observations
```
Note: `init-scripts/` only run on the **first** container startup, when the `pgdata` volume is empty. To re-run them, use `docker compose down -v`.

## Data source

- **Provider:** [World Food Programme](https://www.wfp.org/) — VAM Food Prices
- **Dataset:** Kenya food prices (WFP Food Prices for Kenya)
- **Source:** [HDX / WFP data portal](https://data.humdata.org/dataset/wfp-food-prices-for-kenya) 
- **Date downloaded:** 2026-11-08
- **Coverage:** January 2006 – October 2026
- **Currency:** KES (Kenyan Shilling)

## Current Status
✅ Done
- Postgres + Docker Compose setup
- Schema + initial data load
- Data profiling

🚧 In progress
- Data cleaning decisions (commodity grouping, orphan markets)

🔜 Next
- Analysis queries (price trends, county comparisons)
- Automated CSV refresh
- API layer for dashboards

## License
All rights reserved