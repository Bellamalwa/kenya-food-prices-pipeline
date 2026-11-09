"""Emit fake Kenyan food price events to Kafka every second."""
import json
import random
import time
from datetime import datetime, timezone

from kafka import KafkaProducer

TOPIC = "food-prices"
COMMODITIES = ["maize", "beans", "rice", "sugar"]

producer = KafkaProducer(
    bootstrap_servers=["localhost:9092"],
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
)

print(f"Producing to topic '{TOPIC}'. Press Ctrl+C to stop.")

try:
    while True:
        event = {
            "commodity": random.choice(COMMODITIES),
            "price": round(random.uniform(40, 220), 2),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
        producer.send(TOPIC, event)
        print(f"Sent: {event}")
        time.sleep(1)
except KeyboardInterrupt:
    print("\nStopping producer.")
finally:
    producer.flush()
    producer.close()
