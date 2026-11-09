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
the broader market; 
RQ2 shows which foods are predictable to budget 
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
- Any "national average" analysis is biased toward cereals. 
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
- -- RQ2 filter (in addition to the standard scope)
WHERE pricetype = 'Retail'
  AND category != 'non-food'
  AND date >= '2021-01-01'
  AND NOT (commodity = 'Kale' AND unit = 'Bunch')  -- drop non-dominant unit

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
primarily wholesale/direct.

2026-11-09: Volatility (RQ2) measured by coefficient of variation 
(std/mean of quarterly prices). Rationale: raw std is biased by price 
level; CV normalizes for fair comparison across commodities. Standard 
in food price research.

2026-11-09: "non-food" category (201 rows) excluded from analysis. 
Rationale: research question concerns food prices; "non-food" items 
(e.g. soap, fuel) are not food and would distort trend and volatility 
findings.

2026-11-09 (Quarterly distribution analysis):
- 84 quarters of retail food price data, 2006-Q1 to 2026-Q4
- 2006-2020: ~24 rows/quarter (narrow baseline collection)
- 2021 onward: 300-1700 rows/quarter (expanded collection)
- 2022-Q3: 9 rows (data collection disruption)
- This is a STRUCTURAL BREAK, not a price phenomenon.
- Scope decision: RQ1 and RQ2 restricted to 2021-01-01 to 2026-10-15
  for comparability. Pre-2021 data retained but excluded from analysis.
- Limitation: findings describe the modern WFP collection regime only.

2026-11-09: RQ2 scope confirmed — all commodities have ≥20 retail 
records in the 2021-2026 period. No commodity exclusions necessary 
for volatility analysis. Threshold query returned zero rows.
RQ2 final scope: all retail commodities, 2021-01-01 to 2026-10-15.

2026-11-09: RQ2 scope confirmed — all commodities have ≥26 retail 
records in the 2021-2026 period (min 26, max 1,496, avg 610). No 
commodity exclusions needed for volatility analysis.
RQ1 and RQ2 final scope: 
  Filter = Retail pricetype, exclude 'non-food' category
  Period = 2021-01-01 to 2026-10-15
  Commodities = all (51)
  Volatility measure = coefficient of variation of quarterly prices

2026-11-09 (Unit heterogeneity discovered):
The unit column reveals that commodities are recorded in different 
units: KG (most grains/meat/produce), L (milk, oil), Unit (bananas), 
Head (cabbage), Bunch (some Kale), 500 ML (UHT milk), 200 G (salt). 

Implications:
1. Aggregate "average retail price across all commodities" is 
   MEANINGLESS. It averages prices in incompatible units.
   - The earlier aggregate trend (114 to 217 KES, +90%) is 
     retracted and will not appear in the paper.
2. RQ1 must be redefined. Options:
   a) Restrict to one commodity (recommendation: Maize as primary staple).
   b) Compute a price index (normalized to 100 at start).
   c) Report per-commodity trends without an aggregate.
3. RQ2 (per-commodity volatility) remains valid because CV is 
   computed per commodity, not across commodities. Caveat: 
   commodities recorded in multiple units (Kale: KG + Bunch) must 
   be filtered to the dominant unit.

Decision (to confirm): RQ1 will be reported per-commodity rather than 
aggregated. Maize will be the lead commodity because it is the 
primary staple, consistently recorded in KG, and has the most data.

2026-11-09 (priceflag discovery):
The priceflag column distinguishes observed prices ('actual', 19,365 rows) 
from derived aggregates ('aggregate', 9,643 rows) and mixed 
('actual,aggregate', 290 rows). Aggregate rows are pre-computed averages 
from WFP, not individual observations.

METHODOLOGICAL DECISION: All analyses filter to priceflag = 'actual'. 
Rationale:
1. Aggregate rows are derived from actuals — including both would 
   double-count.
2. Mixing observation-level and pre-aggregated data makes quarterly 
   means semantically ambiguous.
3. Standard WFP analysis convention.
The earlier maize/beans/rice/sugar trends (which mixed priceflag 
values) will be superseded by priceflag='actual'-only analysis.

Also logged: priceflag='actual,aggregate' rows (290) excluded as 
ambiguous.

Cross-commodity finding (preliminary, to verify after priceflag filter):
All four staples (maize, beans, rice, sugar) showed peak prices 
between 2023-Q3 and 2024-Q1, with peak increases of +66.8% to +95.3%. 
This alignment suggests a shared systemic shock (2022-2023 global 
food price crisis / regional drought). Milk (cow, fresh) has only 
~14 quarterly observations — treat findings with caution.

2026-11-09 (priceflag methodology — corrected):
Verified the distribution of priceflag × commodity for 2021-2026:

- Maize:    actual=1,   aggregate=698
- Beans:    actual=0,   aggregate=767 (2021+)
- Rice:     actual=1,   aggregate=772
- Milk:     actual=0,   aggregate=56
- Sugar:    actual=726, aggregate=670 (dual-track), actual,aggregate=103

For the 2021-2026 analysis period, aggregate prices are the ONLY
continuously available series for maize, beans, rice, and milk.
Actual observations are essentially absent (≤1 per commodity).

DECISION: Use aggregate prices for all five commodities. Sugar's
aggregate series is chosen over its actual series for cross-commodity
comparability. Mixed-flag records (actual,aggregate; 103 sugar rows)
are excluded as ambiguous.

Earlier exploratory analysis used aggregate prices by default
(since aggregate dominated 2021+ records), so prior findings
are valid under this methodology.

Prior findings retained:
- Maize retail trend +24.7% (2021-Q1 to 2026-Q4), peak +66.8% (2023-Q3)
- Beans, rice, sugar all show 2023-Q3 to 2024-Q1 peak, in the +67% to 
  +95% range at peak, with partial unwinds by 2026.

2026-11-09 (Milk exclusion — data quality):
Fresh cow milk aggregate records (56 total, 2021-2026) show highly 
fragmented coverage: 14 of 24 quarters have data, and 7 of those 
are single-market observations. 2-year gap (2022-Q2 to 2023-Q4) 
and 3-quarter gap (2024-Q3 to 2025-Q1). The apparent +186% rise is 
an artifact of inconsistent sampling — different markets at 
different prices reported in different quarters.

DECISION: Milk excluded from the primary 2021-2026 comparison. 
Findings discuss maize, beans, rice, sugar only. Milk noted as 
a limitation / future-work item.

2026-11-09 (RQ2 preliminary result — volatility):
Coefficient of variation (CV) across 2021-2026 retail aggregate prices:

- Sugar:   CV 26.04% (std dev 36.71, mean 140.97, n=668)
- Beans:   CV 23.63% (std dev 31.30, mean 132.45, n=765)
- Rice:    CV 23.20% (std dev 28.08, mean 121.02, n=770)
- Maize:   CV 23.06% (std dev 13.36, mean 57.95,  n=698)

KEY FINDING: Volatility is nearly identical across all four staples 
in relative terms (CV range 23.06%–26.04%, spread only 3 percentage 
points). Absolute standard deviation differs substantially (maize 
13.36 vs sugar 36.71), but this reflects price levels, not 
volatility. Sugar's slightly higher CV is consistent with its role 
as a globally-traded commodity.

CAVEAT: CV computed over full 2021-2026 period includes the 2023-
2024 shock. True "underlying" volatility may be lower. Recommended 
robustness check: re-run CV excluding 2023-Q3 to 2024-Q2.

2026-11-09 (RQ2b — underlying volatility excluding shock):
Re-ran CV excluding 2023-07-01 to 2024-06-30 shock window:

- Sugar:  CV 21.30% (was 26.04% full-period)
- Maize:  CV 21.12% (was 23.06%)
- Rice:   CV 20.01% (was 23.20%)
- Beans:  CV 19.16% (was 23.63%)

KEY FINDING: The ranking REVERSES. Full-period CV suggested maize 
was least volatile (23.06%) and sugar most volatile (26.04%) — but 
that was dominated by the shock. Excluding the shock, beans are 
least volatile (19.16%) and sugar + maize are most volatile 
(21.30% and 21.12%).

INTERPRETATION: Two regimes:
1. CRISIS regime (2023-2024): all staples hit simultaneously; 
   magnitude varies with global exposure
2. NORMAL regime: commodity-specific dynamics — beans (domestic, 
   stable supply chains) least volatile; sugar (global market) and 
   maize (seasonal + policy-driven) most volatile

This two-regime finding is the substantive RQ2 contribution.