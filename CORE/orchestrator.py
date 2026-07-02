#!/usr/bin/env python3
"""
MICO-JDEQ Python Orchestration Engine
Pengganti n8n — ringan, native, terintegrasi penuh
"""
import subprocess, json, time, threading, os
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
LOG_DIR = JDEQ / "logs"
os.makedirs(LOG_DIR, exist_ok=True)

class MICOOrchestrator:
    def __init__(self):
        self.workflows = []
        self._load_builtin_workflows()

    def _load_builtin_workflows(self):
        # Workflow 1: Monitoring RAM setiap 5 menit, kirim ke Telegram jika < 500MB
        self.workflows.append({
            "name": "Monitoring RAM",
            "interval": 300,
            "action": self._monitor_ram
        })
        # Workflow 2: Cek koneksi Infinix setiap 10 menit
        self.workflows.append({
            "name": "Cek Infinix",
            "interval": 600,
            "action": self._check_infinix
        })
        # Workflow 3: Backup SSOT setiap jam
        self.workflows.append({
            "name": "Backup SSOT",
            "interval": 3600,
            "action": self._backup_ssot
        })

    def _monitor_ram(self):
        with open("/proc/meminfo") as f:
            for line in f:
                if "MemAvailable" in line:
                    avail = int(line.split()[1]) // 1024
                    if avail < 500:
                        self._notify_telegram(f"⚠️ RAM tersisa {avail} MB!")

    def _check_infinix(self):
        result = subprocess.run(["ping", "-c", "1", "-W", "2", "100.103.39.81"],
                                capture_output=True)
        if result.returncode != 0:
            self._notify_telegram("🔴 Infinix tidak terjangkau!")

    def _backup_ssot(self):
        src = JDEQ / "SSOT"
        dst = JDEQ / "backup" / f"ssot-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
        os.makedirs(dst.parent, exist_ok=True)
        subprocess.run(["cp", "-r", str(src), str(dst)])
        self._log(f"SSOT dibackup ke {dst}")

    def _notify_telegram(self, msg):
        token = "8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8"
        chat_id = "8702459215"
        subprocess.run(["curl", "-s", "-X", "POST",
                        f"https://api.telegram.org/bot{token}/sendMessage",
                        "-d", f"chat_id={chat_id}",
                        "-d", f"text={msg}"], capture_output=True)

    def _log(self, msg):
        with open(LOG_DIR / "orchestrator.log", "a") as f:
            f.write(f"[{datetime.now().isoformat()}] {msg}\n")

    def run(self):
        print("🚀 MICO Python Orchestrator berjalan...")
        for wf in self.workflows:
            t = threading.Thread(target=self._run_workflow, args=(wf,), daemon=True)
            t.start()

    def _run_workflow(self, wf):
        while True:
            try:
                wf["action"]()
            except Exception as e:
                self._log(f"Error di {wf['name']}: {e}")
            time.sleep(wf["interval"])

if __name__ == "__main__":
    orch = MICOOrchestrator()
    orch.run()
    # Jangan berhenti — ini daemon
    import signal
    signal.pause()
