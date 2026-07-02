"""Decision Kernel — Operator Tunggal Depot"""
import json, os, time, subprocess, threading
from pathlib import Path
from datetime import datetime
import paho.mqtt.client as mqtt
from loguru import logger

B = Path.home() / "JDEQ"
LOG_FILE = B / "KERNEL" / "logs" / "decision_kernel.log"
os.makedirs(LOG_FILE.parent, exist_ok=True)
logger.add(LOG_FILE, rotation="1 week", level="INFO")

INDEX_FILE = B / "KERNEL" / "index" / "master_index.json"
QUEUE_MAIN = B / "queue" / "main"
GHOST_RUNNER = B / "scripts" / "ghost_runner.sh"

def handle_input(payload):
    """Semua input dari Event Bridge diproses di sini."""
    logger.info(f"INPUT: {str(payload)[:100]}")

    # Periksa indeks jika diperlukan
    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE) as f:
            index = json.load(f)
        # Catat saja untuk audit
        logger.info(f"Master Index tersedia: {len(index)} folder terindeks")

    # Keputusan default: teruskan ke Ghost Runner
    return {"status": "processed", "timestamp": datetime.now().isoformat()}

def on_connect(client, userdata, flags, rc):
    client.subscribe("jdeq/decision/input")
    logger.info("Decision Kernel (Operator) terhubung")

def on_message(client, userdata, msg):
    payload = msg.payload.decode()
    result = handle_input(payload)
    # Kirim hasil ke topik respons
    client.publish("jdeq/kernel/response", json.dumps(result))
    logger.info(f"Keputusan: {result['status']}")

def ghost_loop():
    while True:
        if os.path.exists(QUEUE_MAIN) and os.listdir(QUEUE_MAIN):
            logger.info("Task ditemukan. Menjalankan Ghost Runner.")
            subprocess.run(["bash", str(GHOST_RUNNER)])
        time.sleep(5)

client = mqtt.Client(client_id="decision-kernel-operator")
client.on_connect = on_connect
client.on_message = on_message
client.connect("127.0.0.1", 1883, 60)
logger.info("Decision Kernel (Operator) AKTIF")

threading.Thread(target=ghost_loop, daemon=True).start()
client.loop_forever()
