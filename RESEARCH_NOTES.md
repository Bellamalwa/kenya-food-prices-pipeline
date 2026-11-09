# Research Notes — Kenya Food Prices Trend

## Research questions

**Overall focus:** The relationship between retail food price trends and 
price volatility in Kenyan markets, 2006–2026.

**RQ1 (Trend):** How have retail food prices in Kenya changed 
quarter-over-quarter from January 2006 to October 2026?

**RQ2 (Volatility):** Which commodities have shown the highest and 
lowest price volatility over that period?

**Scope:** Retail prices only. Wholesale data is loaded but excluded 
from this analysis.

**Volatility measure:** Coefficient of variation (standard deviation / 
mean) of quarterly prices.

## Why this matters

Retail food prices are what Kenyan households pay at local markets. 
RQ1 shows whether the cost of feeding a family is rising in line with 
the broader market; RQ2 shows which foods are predictable to budget 
for versus which need a cushion.

This is directly relevant to:
- Food security analysis (WFP/FAO use retail prices for this)
- Cost-of-living and inflation policy
- Household budgeting and small vendor pricing

Note: retail prices are NOT what restaurant owners pay — they buy 
wholesale or direct from suppliers. A separate pipeline using 
wholesale prices would be the right data source for that audience.

## Who this helps

- Households tracking food affordability
- Food security analysts (WFP/FAO-style monitoring)
- Policy researchers studying cost-of-living and inflation
- Small food vendors pricing goods at market

## What this project will do (vision)

Load 18 years of Kenyan retail food prices into a queryable database and 
analyze two questions: (RQ1) how prices have changed quarter-over-quarter 
since 2006, and (RQ2) which commodities are most and least volatile. 
When new data arrives, re-run the analysis so the answers stay current.

## What this project does today (current state)

Raw CSVs (29,298 price rows, 280 markets) loaded into PostgreSQL via Docker
- Data profiled: 51 commodities, 227 markets with prices, KES only, no NULL prices, 
  two price types (Retail/Wholesale)
- Schema and seed scripts committed
- Analysis queries: not yet written
- Cleaning: retail/wholesale split decided; no transformations applied

## Limitations

- Cannot predict future prices
- Covers only commodities and markets recorded by WFP — not exhaustive
- Market-level prices, not individual supplier invoices
- Wholesale prices loaded but not analyzed in this phase
- 53 markets in the markets table have no price records — regional coverage is uneven

## Methodology (draft)

- Data source: WFP Kenya, downloaded 2026-11-08
- Coverage: 2006-01 to 2026-10, 51 commodities, 227 markets with prices
- Known issues:
  - Retail vs Wholesale must be separated (filter to Retail — decided)
  - 51 commodities have qualifier variants (e.g. "Beans", "Beans (dry)") — 
    kept as-is because RQ2 measures volatility per commodity
  - 53 markets have no price data (retained in markets table; excluded from 
    price analysis by default via JOIN behavior)
- Cleaning decisions: (to be filled)
- Analysis approach: (to be filled)

## Open questions

- Should quarterly analysis use calendar quarters or WFP reporting cycles?
- If a commodity has no price in a quarter, should it be excluded from 
  that quarter's mean, or interpolated from neighbors?
- Do we report volatility per commodity nationally, or per commodity 
  per region (e.g. Maize in Nairobi vs Maize in Turkana)?
- How to handle the 53 markets with no price records — flag them in a 
  footnote, or exclude entirely?

## Log of decisions
2026-11-09: Scope chosen as retail prices, matching household food 
affordability. Audience is food security analysts, households, and 
policy researchers — NOT restaurant owners, whose purchases are 
primarily wholesale/direct. This is documented explicitly in 
RESEARCH_NOTES.md.
2026-11-09: Volatility (RQ2) measured by coefficient of variation 
(std/mean of quarterly prices). Rationale: raw std is biased by price 
level; CV normalizes for fair comparison across commodities. Standard 
in food price research.