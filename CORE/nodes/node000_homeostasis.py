#!/usr/bin/env python3
import os, time, json
LOG = os.path.expanduser("~/JDEQ/logs/homeostasis.log")
while True:
    ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
    health = {"ram_mb": int(ram), "status": "OK" if int(ram) > 500 else "WARNING"}
    with open(LOG, "a") as f: f.write(json.dumps(health) + "\n")
    time.sleep(60)
