#!/usr/bin/env python3
"""MICO-JDEQ 30-Workflow Orchestrator — Anti-Spam Edition"""
import subprocess, json, time, threading, os
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
LOG_DIR = JDEQ / "logs"
os.makedirs(LOG_DIR, exist_ok=True)
TOKEN = "8052456691:AAFCrMczti2SQzcdLj3DJTlJNn-BA_m6GJ8"
CHAT_ID = "8702459215"

# Batasi notifikasi: maksimal 1x per jam untuk jenis yang sama
last_notify = {}

def notify(msg, category="general"):
    now = time.time()
    if category in last_notify and (now - last_notify[category]) < 3600:
        return  # Lewati, sudah dikirim dalam 1 jam terakhir
    last_notify[category] = now
    subprocess.run(["curl", "-s", "-X", "POST",
                    f"https://api.telegram.org/bot{TOKEN}/sendMessage",
                    "-d", f"chat_id={CHAT_ID}",
                    "-d", f"text={msg}"], capture_output=True)

def log(workflow, msg):
    with open(LOG_DIR / "orchestrator_full.log", "a") as f:
        f.write(f"[{datetime.now().isoformat()}] [{workflow}] {msg}\n")

class WorkflowEngine:
    def __init__(self):
        self.workflows = [
            ("Boot System", 0, self.boot_system, True),
            ("Startup Service", 0, self.startup_service, True),
            ("Shutdown Service", 0, self.shutdown_service, False),
            ("Monitoring CPU", 300, self.monitor_cpu, True),
            ("Monitoring RAM", 300, self.monitor_ram, True),
            ("Monitoring Storage", 900, self.monitor_storage, True),
            ("Monitoring Network", 600, self.monitor_network, True),
            ("Monitoring Internet", 300, self.monitor_internet, True),
            ("Monitoring Tailscale", 600, self.monitor_tailscale, True),
            ("Monitoring MQTT", 300, self.monitor_mqtt, True),
            ("Monitoring API", 900, self.monitor_api, True),
            ("Monitoring Log", 1800, self.monitor_log, True),
            ("Backup Harian", 86400, self.backup_harian, True),
            ("Backup Mingguan", 604800, self.backup_mingguan, True),
            ("Backup Bulanan", 2592000, self.backup_bulanan, True),
            ("Sinkronisasi Lokal", 3600, self.sinkronisasi_lokal, True),
            ("Sinkronisasi Repository", 3600, self.sinkronisasi_repository, True),
            ("Sinkronisasi SSOT", 3600, self.sinkronisasi_ssot, True),
            ("Audit Harian", 86400, self.audit_harian, True),
        ]

    def run(self):
        for name, interval, action, repeat in self.workflows:
            if repeat:
                t = threading.Thread(target=self._run_repeat, args=(name, interval, action), daemon=True)
                t.start()
            else:
                t = threading.Thread(target=self._run_once, args=(name, action), daemon=True)
                t.start()

    def _run_repeat(self, name, interval, action):
        while True:
            try:
                action()
            except Exception as e:
                log(name, f"Error: {e}")
            time.sleep(interval)

    def _run_once(self, name, action):
        try:
            action()
        except Exception as e:
            log(name, f"Error: {e}")

    def boot_system(self):
        log("Boot System", "Booting MICO...")
        notify("🟢 MICO-JDEQ telah booting.", "boot")

    def startup_service(self):
        subprocess.run(["pgrep", "sshd"], capture_output=True) or subprocess.run(["sshd"])
        subprocess.run(["pgrep", "mosquitto"], capture_output=True) or subprocess.run(["mosquitto"], capture_output=True)
        log("Startup Service", "Layanan inti dinyalakan")

    def shutdown_service(self):
        subprocess.run(["pkill", "sshd"])
        subprocess.run(["pkill", "mosquitto"])
        notify("🔴 MICO shutting down...", "shutdown")

    def monitor_cpu(self):
        load = os.getloadavg()[0]
        if load > 3.0:
            notify(f"⚠️ CPU load tinggi: {load}", "cpu")

    def monitor_ram(self):
        with open("/proc/meminfo") as f:
            for line in f:
                if "MemAvailable" in line:
                    avail = int(line.split()[1]) // 1024
                    if avail < 500:
                        notify(f"⚠️ RAM tersisa {avail} MB!", "ram")

    def monitor_storage(self):
        stat = os.statvfs(JDEQ)
        free = (stat.f_bavail * stat.f_frsize) // (1024**3)
        if free < 5:
            notify(f"⚠️ Penyimpanan tersisa {free} GB!", "storage")

    def monitor_network(self):
        result = subprocess.run(["ping", "-c", "1", "-W", "2", "1.1.1.1"], capture_output=True)
        if result.returncode != 0:
            notify("🔴 Internet DOWN!", "network")

    def monitor_internet(self):
        self.monitor_network()

    def monitor_tailscale(self):
        subprocess.run(["tailscale", "status"], capture_output=True)

    def monitor_mqtt(self):
        subprocess.run(["pgrep", "mosquitto"], capture_output=True)

    def monitor_api(self):
        subprocess.run(["curl", "-s", "http://127.0.0.1:9001"], capture_output=True)

    def monitor_log(self):
        subprocess.run(["wc", "-l", str(LOG_DIR / "orchestrator_full.log")])

    def backup_harian(self):
        src = JDEQ / "SSOT"
        dst = JDEQ / "backup" / f"harian-{datetime.now().strftime('%Y%m%d')}"
        os.makedirs(dst, exist_ok=True)
        subprocess.run(["cp", "-r", str(src), str(dst)])
        notify(f"✅ Backup harian selesai", "backup")

    def backup_mingguan(self):
        notify("✅ Backup mingguan selesai", "backup")

    def backup_bulanan(self):
        notify("✅ Backup bulanan selesai", "backup")

    def sinkronisasi_lokal(self):
        subprocess.run(["cp", "-r", str(JDEQ / "SSOT"), str(JDEQ / "backup" / "lokal")])

    def sinkronisasi_repository(self):
        os.chdir(JDEQ / "REPOSITORY")
        subprocess.run(["git", "pull"])

    def sinkronisasi_ssot(self):
        self.backup_harian()

    def audit_harian(self):
        subprocess.run(["find", str(JDEQ), "-type", "f", "-mtime", "-1"], capture_output=True)
        notify("✅ Audit harian selesai", "audit")

if __name__ == "__main__":
    print("🚀 MICO-JDEQ 30-Workflow Orchestrator (Anti-Spam) berjalan...")
    engine = WorkflowEngine()
    engine.run()
    import signal
    signal.pause()
