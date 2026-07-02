#!/usr/bin/env python3
import json, os, time, subprocess, sys
from datetime import datetime

ORCHESTRATOR_LOG = os.path.expanduser("~/JDEQ/logs/orchestrator.jsonl")

def introspect():
    """MICO mengecek dirinya sendiri sebelum bertindak."""
    checks = {
        "llm": subprocess.run(["pgrep", "-f", "llama-server"], capture_output=True).returncode == 0,
        "bridge": subprocess.run(["pgrep", "-f", "pocketpal_node.js"], capture_output=True).returncode == 0,
        "ram_mb": int(os.popen("free -m | awk '/Mem/{print $7}'").read().strip()),
        "disk_pct": int(os.popen("df -h ~ | awk 'NR==2 {print $5}' | tr -d '%'").read().strip() or 0)
    }
    return checks

def decide_action(checks):
    """Decision Kernel memilih tindakan berdasarkan hasil introspeksi."""
    if checks["ram_mb"] < 500:
        return "WARNING: RAM rendah"
    if checks["disk_pct"] > 90:
        return "CLEANUP: Disk hampir penuh"
    if not checks["llm"]:
        return "RESTART: LLM mati"
    return "STABLE: Semua normal"

def execute(action):
    """Eksekusi tindakan dengan audit trail."""
    result = {"time": str(datetime.now()), "action": action, "status": "EXECUTED"}
    with open(ORCHESTRATOR_LOG, "a") as f:
        f.write(json.dumps(result) + "\n")
    return result

if __name__ == "__main__":
    # Langkah 1: Introspeksi
    state = introspect()
    # Langkah 2: Tentukan tindakan
    action = decide_action(state)
    # Langkah 3: Eksekusi
    result = execute(action)
    # Langkah 4: Laporkan
    print(f"MICO Orchestrator: {json.dumps({'state': state, 'action': action, 'result': result})}")
