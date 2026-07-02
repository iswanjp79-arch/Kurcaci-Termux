#!/usr/bin/env python3
"""Runtime Governance — Budget CPU/RAM, Timeout, Termination Condition"""
import os, time, signal

class RuntimeGovernance:
    def __init__(self):
        self.budget = {
            "cpu_max": 2.0,        # Load average maksimum
            "ram_min_mb": 300,     # RAM minimum sebelum terminate
            "timeout_sec": 30,     # Timeout eksekusi
            "retry_max": 3         # Maksimum retry sebelum stop
        }
        self.retry_count = {}
    
    def check_budget(self, worker_name):
        """Periksa apakah worker masih dalam budget"""
        ram = int(os.popen("free -m | awk '/Mem/{print $7}'").read().strip())
        cpu = float(os.popen("cat /proc/loadavg 2>/dev/null | awk '{print $1}'").read().strip() or 0)
        
        violations = []
        if ram < self.budget["ram_min_mb"]:
            violations.append(f"RAM_LOW: {ram}MB < {self.budget['ram_min_mb']}MB")
        if cpu > self.budget["cpu_max"]:
            violations.append(f"CPU_HIGH: {cpu} > {self.budget['cpu_max']}")
        
        if violations:
            return {"status": "TERMINATE", "violations": violations}
        return {"status": "OK"}
    
    def track_retry(self, worker_name):
        """Lacak jumlah retry, terminate jika melebihi batas"""
        self.retry_count[worker_name] = self.retry_count.get(worker_name, 0) + 1
        if self.retry_count[worker_name] > self.budget["retry_max"]:
            return {"status": "TERMINATE", "reason": f"MAX_RETRY_EXCEEDED: {self.retry_count[worker_name]}"}
        return {"status": "RETRY", "count": self.retry_count[worker_name]}

if __name__ == "__main__":
    g = RuntimeGovernance()
    print(f"✅ Budget Check: {g.check_budget('test_worker')}")
    print(f"✅ Retry Track: {g.track_retry('test_worker')}")
