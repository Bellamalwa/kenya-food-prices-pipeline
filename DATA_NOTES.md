# Data Profile Notes — Kenya Food Prices

Profiling observations from the WFP Kenya food prices dataset, recorded during exploratory analysis. These findings drove the methodology decisions documented in `RESEARCH_NOTES.md` and `paper/paper.md`.

## Source

- **Provider:** World Food Programme (WFP) — VAM Food Prices
- **Dataset:** Kenya food prices, via Humanitarian Data Exchange (HDX)
- **Files:** `data/raw/wfp_food_prices_ken.csv`, `data/raw/wfp_markets_ken.csv`
- **Files dated:** 2026-11-08
- **Currency:** KES only — no conversion required

## Shape

| Measure | Value |
|---|---|
| Total price records | 29,298 |
| Distinct commodities | 51 |
| Distinct categories | 8 |
| Distinct markets with prices | 227 (out of 280 in the markets table) |
| Date range | 2006-01-15 to 2026-10-15 (~20 years) |
| NULL prices | 0 |
| Zero prices | 0 |

## Categories and volumes

| Category | Rows | % of total |
|---|---|---|
| Cereals and tubers | 12,866 | 43.9% |
| Pulses and nuts | 5,124 | 17.5% |
| Vegetables and fruits | 3,375 | 11.5% |
| Miscellaneous food | 2,959 | 10.1% |
| Oil and fats | 1,882 | 6.4% |
| Milk and dairy | 1,748 | 6.0% |
| Meat, fish and eggs | 1,143 | 3.9% |
| Non-food | 201 | 0.7% |

**Implication:** cereals and tubers dominate the dataset — any "average across all commodities" is heavily weighted toward cereals. Analysis is per-commodity, not aggregated.

## Price types

| pricetype | Rows |
|---|---|
| Retail | ~14,650 |
| Wholesale | ~14,648 |

**Implication:** averaging across both mixes two different market stages. All analysis filters to `Retail`.

## Price flags

| priceflag | Rows | Meaning |
|---|---|---|
| actual | 19,365 | Direct market observations |
| aggregate | 9,643 | WFP-computed market-level prices |
| actual,aggregate | 290 | Ambiguous — excluded |

**Per-commodity breakdown (2021–2026, Retail):**

| Commodity | actual | aggregate |
|---|---|---|
| Maize | 1 | 698 |
| Beans (dry) | 0 | 765 |
| Rice | 1 | 770 |
| Milk (cow, fresh) | 0 | 56 |
| Sugar | 725 | 668 |

**Implication:** for the 2021–2026 period, the aggregate series is the only continuously available series for most commodities. All analysis uses `priceflag = 'aggregate'`. The `actual,aggregate` rows are excluded as ambiguous.

## Unit heterogeneity

| Commodity | Unit |
|---|---|
| Most grains, produce, meat | KG |
| Milk (fresh, camel, pasteurized), cooking oil | L |
| Bananas | Unit |
| Cabbage | Head |
| Kale (some records) | Bunch |
| Milk (UHT) | 500 ML |
| Salt | 200 G |

**Implication:** prices cannot be averaged across commodities — a banana per unit and goat meat per kg are not commensurable. All analysis is per-commodity. Kale is recorded in both KG (413 rows) and Bunch (21 rows); analysis uses KG only.

## Structural break — 2021

Quarterly record counts show a discontinuity:

- **2006–2020:** ~24 records per quarter — narrow baseline collection
- **2021 onward:** 300–1,700 records per quarter — expanded collection regime
- **2022 Q2 and Q3:** 0–9 records — data collection gap

**Implication:** a naïve analysis across 2006–2026 would conflate the change in collection volume with a change in food prices. All analysis is restricted to **2021-01-01 to 2026-10-15**, where coverage is consistent.

## Orphan markets

- **280** markets in the markets metadata table
- **227** markets with price records
- **53 orphan markets** — in metadata, no prices recorded

The orphans are not randomly distributed — they cluster in specific counties (e.g., 6+ in Mombasa, 2+ in Garissa, at least 1 in Turkana). This is either a data-quality gap or a monitoring gap; the pipeline excludes them by default (INNER JOIN behavior).

## Milk sparsity

Milk (cow, fresh) has 56 aggregate records across 24 quarters:

- **14 of 24 quarters have data**
- **7 of those 14 have a single market reporting**
- **2-year gap** (2022 Q2 – 2023 Q4)
- **3-quarter gap** (2024 Q3 – 2025 Q1)

**Implication:** volatility estimates for milk would reflect which market happened to report, not underlying dairy price dynamics. **Milk is excluded from the primary analysis** and documented as a limitation.

## Final analysis sample

- **Filter set:** `pricetype = 'Retail'` AND `priceflag = 'aggregate'` AND `category != 'non-food'` AND `date >= '2021-01-01'`
- **Commodities:** maize, dry beans, rice, sugar
- **Records:** 2,901 (maize 698, beans 765, rice 770, sugar 668)
- **Quarterly record counts:** min 3, max 328, mean 132

## Reproducing this profile

All numbers above are reproducible from the repo:

```bash
make pipeline   # loads and transforms the data