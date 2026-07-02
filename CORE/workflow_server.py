#!/usr/bin/env python3
"""MICO STABLE WORKFLOW ENGINE + DASHBOARD"""
import json, os, time, subprocess, threading
from datetime import datetime
from pathlib import Path
from flask import Flask, jsonify

app = Flask(__name__)
JDEQ = Path.home() / "JDEQ"
LOG_DIR = JDEQ / "logs"
os.makedirs(LOG_DIR, exist_ok=True)

# Status workflow
WORKFLOW_STATUS = {}

def run_every(seconds, name, func):
    """Jalankan fungsi setiap X detik, catat status"""
    while True:
        try:
            func()
            WORKFLOW_STATUS[name] = {"status": "OK", "last_run": str(datetime.now())}
        except Exception as e:
            WORKFLOW_STATUS[name] = {"status": "ERROR", "error": str(e)}
        time.sleep(seconds)

# Fungsi monitoring
def monitor_ram():
    with open("/proc/meminfo") as f:
        for line in f:
            if "MemAvailable" in line:
                avail = int(line.split()[1]) // 1024
                if avail < 500:
                    subprocess.run(["termux-notification", "--title", "MICO", "--content", f"RAM: {avail}MB"])

def monitor_storage():
    stat = os.statvfs(JDEQ)
    free_gb = (stat.f_bavail * stat.f_frsize) // (1024**3)
    if free_gb < 5:
        subprocess.run(["termux-notification", "--title", "MICO", "--content", f"Storage: {free_gb}GB"])

def backup_ssot():
    src = JDEQ / "SSOT"
    dst = JDEQ / "backup" / f"auto-{datetime.now().strftime('%Y%m%d-%H%M')}"
    os.makedirs(dst, exist_ok=True)
    subprocess.run(["cp", "-r", str(src), str(dst)])

def check_infinix():
    result = subprocess.run(["ping", "-c", "1", "-W", "2", "100.103.39.81"], capture_output=True)
    if result.returncode != 0:
        subprocess.run(["termux-notification", "--title", "MICO", "--content", "Infinix OFFLINE"])

# API Endpoint
@app.route('/')
def dashboard():
    return """
    <html><head><title>MICO Dashboard</title>
    <meta http-equiv='refresh' content='10'/></head>
    <body style='background:#111;color:#0f0;font-family:monospace;padding:20px'>
    <h1>🏗️ MICO-JDEQ WORKFLOW DASHBOARD</h1>
    <p>Stable Edition — No N8N Required</p>
    <hr>
    <h2>Status Workflows:</h2>
    <pre>""" + json.dumps(WORKFLOW_STATUS, indent=2) + """</pre>
    <hr>
    <p>🟢 Running on Vivo Y28 | Tailscale IP: 100.123.232.84</p>
    </body></html>"""

@app.route('/health')
def health():
    return jsonify({"status": "OK", "workflows": WORKFLOW_STATUS})

@app.route('/trigger/<name>')
def trigger(name):
    if name == "backup":
        backup_ssot()
        return jsonify({"triggered": name, "status": "OK"})
    elif name == "check":
        check_infinix()
        return jsonify({"triggered": name, "status": "OK"})
    return jsonify({"triggered": name, "status": "NOT_FOUND"})

if __name__ == "__main__":
    # Jalankan workflow di background
    for name, interval, func in [
        ("Monitor RAM", 300, monitor_ram),
        ("Monitor Storage", 900, monitor_storage),
        ("Backup SSOT", 3600, backup_ssot),
        ("Cek Infinix", 600, check_infinix),
    ]:
        t = threading.Thread(target=run_every, args=(interval, name, func), daemon=True)
        t.start()
    # Jalankan web server
    app.run(host="0.0.0.0", port=5678)
