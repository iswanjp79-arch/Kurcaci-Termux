import json, os, threading, time
from pathlib import Path
from datetime import datetime
import paho.mqtt.client as mqtt
from loguru import logger

B = Path.home() / "JDEQ"
LOG_FILE = B / "KERNEL" / "logs" / "kernel_daemon.log"
INDEX_FILE = B / "KERNEL" / "index" / "master_index.json"
os.makedirs(LOG_FILE.parent, exist_ok=True)
logger.add(LOG_FILE, rotation="1 week", level="INFO")

def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
    except:
        payload = {"agent":"unknown","request":msg.payload.decode()}
    agent = payload.get("agent","unknown")
    request = payload.get("request","")

    if os.path.exists(INDEX_FILE):
        with open(INDEX_FILE) as f:
            index = json.load(f)
    else:
        index = {}

    result = {"status":"not_found","agent":agent}
    for folder, files in index.items():
        for file in files:
            if request.lower() in file["name"].lower():
                result = {"status":"found","agent":agent,"path":file["path"],"folder":folder,"file":file["name"]}
                break
        if result["status"]=="found":
            break

    logger.info(f"{agent} → {request[:60]} → {result['status']}")
    client.publish("jdeq/kernel/response", json.dumps(result))

client = mqtt.Client(client_id="kernel-daemon")
client.on_message = on_message
client.connect("127.0.0.1", 1883, 60)
client.subscribe("jdeq/kernel/request")
logger.info("KERNEL DAEMON AKTIF")
client.loop_forever()
