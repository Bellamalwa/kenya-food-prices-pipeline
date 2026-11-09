"""Consume price events from Kafka and write them to Postgres.

Guarantee: at-least-once. Kafka offsets are committed only after the
Postgres transaction commits. Duplicates are possible on crash/restart;
the INSERT ... ON CONFLICT clause makes replays idempotent.
"""
import json
import os
import signal
import sys
import time

import psycopg2
from kafka import KafkaConsumer
from dotenv import load_dotenv

load_dotenv()

TOPIC = "food-prices"
BATCH_SIZE = 50
BATCH_TIMEOUT_SECONDS = 5

DSN = (
    f"host=localhost port={os.getenv('POSTGRES_PORT', 5432)} "
    f"dbname={os.getenv('POSTGRES_DB')} "
    f"user={os.getenv('POSTGRES_USER')} "
    f"password={os.getenv('POSTGRES_PASSWORD')}"
)

INSERT_SQL = """
INSERT INTO streamed_prices (commodity, price, event_time)
VALUES (%s, %s, %s)
ON CONFLICT (commodity, event_time) DO NOTHING;
"""


def connect_db():
    conn = psycopg2.connect(DSN)
    conn.autocommit = False
    return conn


def main():
    consumer = KafkaConsumer(
        TOPIC,
        bootstrap_servers=["localhost:9092"],
        auto_offset_reset="earliest",
        enable_auto_commit=False,
        group_id="price-sink",
        value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    )

    print(f"Sinking '{TOPIC}' to Postgres. Ctrl+C to stop.")
    conn = connect_db()
    cur = conn.cursor()

    buffer = []
    last_flush = time.time()

    def flush():
        nonlocal buffer, last_flush
        if not buffer:
            return
        try:
            cur.executemany(INSERT_SQL, buffer)
            conn.commit()
            print(f"Flushed {len(buffer)} rows.")
            buffer = []
            last_flush = time.time()
        except Exception:
            conn.rollback()
            raise

    def shutdown(sig, frame):
        print("\nShutting down: flushing buffer and closing.")
        flush()
        cur.close()
        conn.close()
        consumer.close()
        sys.exit(0)

    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)

    try:
        for message in consumer:
            event = message.value
            buffer.append(
                (event["commodity"], event["price"], event["timestamp"])
            )
            if len(buffer) >= BATCH_SIZE or (
                time.time() - last_flush
            ) >= BATCH_TIMEOUT_SECONDS:
                flush()
                consumer.commit()
    finally:
        flush()
        consumer.commit()
        cur.close()
        conn.close()
        consumer.close()


if __name__ == "__main__":
    main()