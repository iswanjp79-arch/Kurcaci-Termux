#!/usr/bin/env python3
import subprocess
for s in ["llama-server","ghost_relay.py","mosquitto","ngrok"]:
    if not subprocess.run(["pgrep","-f",s], capture_output=True).stdout:
        print(f"⚠️ {s} mati")
