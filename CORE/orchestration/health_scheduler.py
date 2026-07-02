import os, subprocess, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
HEALTH_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/health_check.log")

def run_health_check():
    """Jalankan pengecekan kesehatan MICO secara ringan."""
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    checks = {}
    # Cek supervisor
    supervisor = os.path.isfile(os.path.join(JDEQ, "supervisor_jdeq.sh"))
    checks["supervisor_script"] = "OK" if supervisor else "MISSING"
    
    # Cek Python
    try:
        subprocess.run(["python3", "-c", "pass"], check=True, capture_output=True)
        checks["python3"] = "OK"
    except:
        checks["python3"] = "FAIL"
    
    # Cek disk
    stat = os.statvfs(JDEQ)
    free_pct = (stat.f_bavail / stat.f_blocks) * 100 if stat.f_blocks else 0
    checks["disk_free_pct"] = f"{free_pct:.1f}%"
    
    # Tulis log
    with open(HEALTH_LOG, "a") as f:
        f.write(f"[{ts}] HEALTH {json.dumps(checks)}\n")
    
    print(f"[HEALTH] {ts} – {json.dumps(checks)}")

if __name__ == "__main__":
    run_health_check()
