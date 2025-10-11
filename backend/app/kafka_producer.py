import json
import os
from typing import Any, Dict

from kafka import KafkaProducer


KAFKA_BROKER = os.getenv("KAFKA_BROKER", "redpanda:9092")
KAFKA_TOPIC = os.getenv("KAFKA_TOPIC", "todo-events")

_producer = None


def get_producer() -> KafkaProducer:
    global _producer
    if _producer is None:
        _producer = KafkaProducer(
            bootstrap_servers=KAFKA_BROKER,
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
            api_version_auto_timeout_ms=60000,
        )
    return _producer


def emit_event(event: Dict[str, Any]) -> None:
    try:
        producer = get_producer()
        producer.send(KAFKA_TOPIC, event)
        producer.flush()
    except Exception:
        # Non-blocking in dev: if broker is down, skip emitting to avoid failing API requests
        pass


