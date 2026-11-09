"""Generate figures for the paper from pipeline output CSVs."""
import pandas as pd
import matplotlib.pyplot as plt
import glob

# Find the most recent CSVs
trends_file = sorted(glob.glob("output/quarterly_trends_*.csv"))[-1]
vol_file = sorted(glob.glob("output/commodity_volatility_*.csv"))[-1]

trends = pd.read_csv(trends_file)
vol = pd.read_csv(vol_file)

trends["quarter"] = pd.to_datetime(trends["quarter"])

# --- Figure 1: Quarterly price trends ---
fig, ax = plt.subplots(figsize=(10, 6))

for commodity in ["Maize", "Beans (dry)", "Rice", "Sugar"]:
    subset = trends[trends["commodity"] == commodity].sort_values("quarter")
    ax.plot(subset["quarter"], subset["avg_price"], marker="o", label=commodity, linewidth=2, markersize=4)

ax.set_xlabel("Quarter")
ax.set_ylabel("Average retail price (KES per KG)")
ax.set_title("Retail staple prices in Kenya, 2021-Q1 to 2026-Q4")
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("paper/figure1_trends.png", dpi=150)
print("Saved paper/figure1_trends.png")
plt.close()

# --- Figure 2: CV comparison ---
fig, ax = plt.subplots(figsize=(9, 5))

x = range(len(vol))
width = 0.38

ax.bar([i - width/2 for i in x], vol["cv_pct_full"], width, label="Full period", color="#3b82f6")
ax.bar([i + width/2 for i in x], vol["cv_pct_excl_shock"], width, label="Excluding 2023-24 shock", color="#f59e0b")

ax.set_xticks(list(x))
ax.set_xticklabels(vol["commodity"], rotation=15)
ax.set_ylabel("Coefficient of variation (%)")
ax.set_title("Price volatility: full period vs. shock-excluded")
ax.legend()
ax.grid(True, axis="y", alpha=0.3)

for i, (full, excl) in enumerate(zip(vol["cv_pct_full"], vol["cv_pct_excl_shock"])):
    ax.text(i - width/2, full + 0.3, f"{full:.1f}", ha="center", fontsize=9)
    ax.text(i + width/2, excl + 0.3, f"{excl:.1f}", ha="center", fontsize=9)

plt.tight_layout()
plt.savefig("paper/figure2_volatility.png", dpi=150)
print("Saved paper/figure2_volatility.png")
plt.close()
