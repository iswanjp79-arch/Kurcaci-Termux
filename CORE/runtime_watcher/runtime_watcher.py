#!/usr/bin/env python3
"""Runtime Watcher — bukan daemon permanen, hanya diaktifkan oleh Kernel saat event"""
import os, json, time
from datetime import datetime

class RuntimeWatcher:
    def __init__(self):
        self.alerts = []
    
    def watch(self, event_type):
        """Dipanggil oleh Event Bus saat ada event runtime"""
        ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
        cpu = os.popen("cat /proc/loadavg 2>/dev/null | awk '{print $1}'").read().strip()
        
        report = {
            "time": str(datetime.now()),
            "event": event_type,
            "ram_mb": int(ram) if ram.isdigit() else 0,
            "cpu_load": float(cpu) if cpu else 0,
            "llm_alive": os.system("pgrep llama-server > /dev/null 2>&1") == 0
        }
        
        # Deteksi anomali
        if report["ram_mb"] < 500:
            self.alerts.append({"type": "RAM_LOW", "value": report["ram_mb"]})
        if report["cpu_load"] > 2.0:
            self.alerts.append({"type": "CPU_HIGH", "value": report["cpu_load"]})
        if not report["llm_alive"]:
            self.alerts.append({"type": "LLM_DEAD"})
        
        return report
    
    def get_alerts(self):
        return self.alerts

# Demo
if __name__ == "__main__":
    w = RuntimeWatcher()
    r = w.watch("MANUAL_CHECK")
    print(f"✅ Runtime Watcher: RAM={r['ram_mb']}MB, CPU={r['cpu_load']}, LLM={'OK' if r['llm_alive'] else 'MATI'}")
    if w.get_alerts():
        print(f"⚠️ Alerts: {w.get_alerts()}")
