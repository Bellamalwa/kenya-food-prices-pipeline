"""Read price events from Kafka and print them."""
import json

from kafka import KafkaConsumer

TOPIC = "food-prices"

consumer = KafkaConsumer(
    TOPIC,
    bootstrap_servers=["localhost:9092"],
    auto_offset_reset="earliest",
    group_id="price-monitor",
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
)

print(f"Consuming from topic '{TOPIC}'. Press Ctrl+C to stop.")

try:
    for message in consumer:
        event = message.value
        print(f"Received: {event['commodity']} at KES {event['price']} "
              f"({event['timestamp']})")
except KeyboardInterrupt:
    print("\nStopping consumer.")
finally:
    consumer.close()
