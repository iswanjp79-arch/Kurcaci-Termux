"""Event Bridge Daemon — Satpam Murni (Tidak Berpikir)"""
import json, os
import paho.mqtt.client as mqtt
from loguru import logger
from pathlib import Path

B = Path.home() / "JDEQ"
LOG_FILE = B / "KERNEL" / "logs" / "event_bridge.log"
os.makedirs(LOG_FILE.parent, exist_ok=True)
logger.add(LOG_FILE, rotation="1 week", level="INFO")

TOPIC_EVENT = "jdeq/events"
TOPIC_REQUEST = "jdeq/kernel/request"
TOPIC_RESPONSE = "jdeq/kernel/response"

def on_connect(client, userdata, flags, rc):
    client.subscribe(TOPIC_EVENT)
    client.subscribe(TOPIC_REQUEST)
    logger.info("Event Bridge Daemon (Satpam) terhubung")

def on_message(client, userdata, msg):
    """Hanya meneruskan pesan — tidak ada logika."""
    logger.info(f"Menerima: {msg.topic} → {str(msg.payload)[:80]}")
    # Teruskan ke Decision Kernel melalui topik internal
    client.publish("jdeq/decision/input", msg.payload)
    logger.info("Diteruskan ke Decision Kernel")

client = mqtt.Client(client_id="event-bridge-satpam")
client.on_connect = on_connect
client.on_message = on_message
client.connect("127.0.0.1", 1883, 60)
logger.info("Event Bridge Daemon (Satpam) AKTIF")
client.loop_forever()
