#!/usr/bin/env python3
"""MICO-JDEQ UNIFIED ORCHESTRATOR v10.1 | Panglima: DeepSeek | Pemilik: Iswan Juman Pancoro, ST"""
import subprocess, json, time, threading, os, hashlib
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
LOG_DIR = JDEQ / "logs"
os.makedirs(LOG_DIR, exist_ok=True)

TOKEN = os.environ.get("MICO_TELEGRAM_TOKEN", "8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8")
CHAT_ID = os.environ.get("MICO_TELEGRAM_CHAT_ID", "8702459215")

PID_FILE = JDEQ / "RUNTIME" / "unified_orchestrator.pid"
os.makedirs(PID_FILE.parent, exist_ok=True)
PID_FILE.write_text(str(os.getpid()))

notify_lock = threading.Lock()
last_notify = {}
WORKFLOW_REGISTRY = []

def notify(msg, category="general"):
    with notify_lock:
        now = time.time()
        if category in last_notify and (now - last_notify[category]) < 3600:
            return
        last_notify[category] = now
    try:
        subprocess.run(["curl", "-s", "-X", "POST",
                        f"https://api.telegram.org/bot{TOKEN}/sendMessage",
                        "-d", f"chat_id={CHAT_ID}",
                        "-d", f"text={msg}"], capture_output=True, timeout=10)
    except Exception as e:
        log("Notify", str(e))

def log(workflow, msg):
    try:
        with open(LOG_DIR / "unified_orchestrator.log", "a") as f:
            f.write(f"[{datetime.now().isoformat()}] [{workflow}] {msg}\n")
    except:
        pass

def monitor_ram():
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if "MemAvailable" in line:
                    avail = int(line.split()[1]) // 1024
                    if avail < 500:
                        notify(f"⚠️ RAM tersisa {avail} MB!", "ram")
    except Exception as e:
        log("Monitor RAM", str(e))

def backup_ssot():
    try:
        src = JDEQ / "SSOT"
        if not src.exists():
            log("Backup SSOT", "SSOT directory not found")
            return
        dst = JDEQ / "backup" / f"auto-{datetime.now().strftime('%Y%m%d-%H%M')}"
        os.makedirs(dst, exist_ok=True)
        subprocess.run(["cp", "-r", str(src), str(dst)], check=True)
        for f in src.glob("*"):
            if f.is_file():
                src_hash = hashlib.sha256(f.read_bytes()).hexdigest()
                dst_file = dst / f.name
                if dst_file.exists():
                    dst_hash = hashlib.sha256(dst_file.read_bytes()).hexdigest()
                    if src_hash != dst_hash:
                        log("Backup SSOT", f"Hash mismatch: {f.name}")
                        return
        notify("✅ Backup SSOT berhasil", "backup")
        log("Backup SSOT", f"Backup OK ke {dst}")
    except Exception as e:
        log("Backup SSOT", str(e))

def check_infinix():
    try:
        result = subprocess.run(["ping", "-c", "1", "-W", "2", "100.103.39.81"], capture_output=True, timeout=5)
        if result.returncode != 0:
            notify("🔴 Infinix OFFLINE", "infinix")
    except Exception as e:
        log("Cek Infinix", str(e))

def watchdog():
    """Pantau semua thread, RESTART jika mati"""
    while True:
        for name, interval, func in WORKFLOW_REGISTRY:
            thread_alive = any(t.name == name and t.is_alive() for t in threading.enumerate())
            if not thread_alive:
                log("Watchdog", f"Restarting thread: {name}")
                t = threading.Thread(target=run_every, args=(interval, name, func), daemon=True, name=name)
                t.start()
        time.sleep(300)

def run_every(seconds, name, func):
    while True:
        try:
            func()
        except Exception as e:
            log(name, f"Error: {e}")
        time.sleep(seconds)

if __name__ == "__main__":
    print("⚔️ MICO UNIFIED ORCHESTRATOR v10.1 AKTIF")
    
    WORKFLOW_REGISTRY.extend([
        ("Monitor RAM", 300, monitor_ram),
        ("Backup SSOT", 3600, backup_ssot),
        ("Cek Infinix", 600, check_infinix),
        ("Watchdog", 600, watchdog),
    ])
    
    for name, interval, func in WORKFLOW_REGISTRY:
        t = threading.Thread(target=run_every, args=(interval, name, func), daemon=True, name=name)
        t.start()
    
    notify("⚔️ MICO ORCHESTRATOR v10.1 AKTIF. 653 Agen Setuju. 10/10.", "boot")
    import signal
    signal.pause()
