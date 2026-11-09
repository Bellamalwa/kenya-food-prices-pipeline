# serve/export_summary.py
import os
from dotenv import load_dotenv    # ← NEW LINE

load_dotenv() 
import psycopg2
import csv
from datetime import datetime

conn = psycopg2.connect(
    host="localhost",
    port=os.getenv("POSTGRES_PORT", 5432),
    database=os.getenv("POSTGRES_DB"),
    user=os.getenv("POSTGRES_USER"),
    password=os.getenv("POSTGRES_PASSWORD"),
)

output_dir = "output"
os.makedirs(output_dir, exist_ok=True)
timestamp = datetime.now().strftime("%Y-%m-%d")

# Export quarterly trends
with conn.cursor() as cur:
    cur.execute("SELECT * FROM quarterly_trends ORDER BY commodity, quarter;")
    with open(f"{output_dir}/quarterly_trends_{timestamp}.csv", "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([desc[0] for desc in cur.description])
        writer.writerows(cur.fetchall())

# Export volatility summary
with conn.cursor() as cur:
    cur.execute("SELECT * FROM commodity_volatility ORDER BY cv_pct_full DESC;")
    with open(f"{output_dir}/commodity_volatility_{timestamp}.csv", "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow([desc[0] for desc in cur.description])
        writer.writerows(cur.fetchall())

print(f"Exported on {timestamp}")
conn.close()