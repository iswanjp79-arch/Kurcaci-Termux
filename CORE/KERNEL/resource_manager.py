#!/usr/bin/env python3
import os, json
def get_resources():
    ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
    disk = os.popen("df -h ~ | awk 'NR==2 {print $5}'").read().strip()
    return {"ram_free_mb": int(ram) if ram.isdigit() else 0, "disk_used_pct": disk}
if __name__ == "__main__":
    print(f"Resources: {json.dumps(get_resources(), indent=2)}")
    print("✅ Resource Manager aktif")
