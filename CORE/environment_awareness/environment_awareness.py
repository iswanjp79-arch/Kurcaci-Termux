#!/usr/bin/env python3
"""Environment Awareness — Mengenali lingkungan."""
import json, subprocess
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
ENV_FILE = JDEQ / "state" / "environment_state.json"

class EnvironmentAwareness:
    def __init__(self):
        self.state = self._scan()
    
    def _scan(self):
        env = {"timestamp": str(datetime.now())}
        # RAM
        try:
            with open("/proc/meminfo") as f:
                for line in f:
                    if "MemAvailable" in line:
                        env["ram_available_mb"] = int(line.split()[1]) // 1024
                    if "MemTotal" in line:
                        env["ram_total_mb"] = int(line.split()[1]) // 1024
        except:
            env["ram_available_mb"] = 0
            env["ram_total_mb"] = 0
        # Storage
        try:
            df = subprocess.run(["df", "-h", str(JDEQ)], capture_output=True, text=True)
            env["storage"] = df.stdout.splitlines()[-1] if df.stdout else "unknown"
        except:
            env["storage"] = "unknown"
        # Network
        try:
            ping = subprocess.run(["ping", "-c", "1", "-W", "2", "8.8.8.8"], capture_output=True)
            env["network"] = "UP" if ping.returncode == 0 else "DOWN"
        except:
            env["network"] = "UNKNOWN"
        
        ENV_FILE.parent.mkdir(parents=True, exist_ok=True)
        ENV_FILE.write_text(json.dumps(env, indent=2))
        return env

if __name__ == "__main__":
    ea = EnvironmentAwareness()
    print("Lingkungan:", json.dumps(ea.state, indent=2))
