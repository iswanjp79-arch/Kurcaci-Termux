import os, subprocess, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
RECOVERY_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/recovery.log")

def log_recovery(event, action, result):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(RECOVERY_LOG, "a") as f:
        f.write(f"[{ts}] RECOVERY [{result}] [{event}] → {action}\n")
    print(f"[RECOVERY] {event} → {action} ({result})")

def check_supervisor():
    """Cek apakah supervisor daemon berjalan."""
    try:
        result = subprocess.run(["pgrep", "-f", "supervisor_jdeq.sh"], 
                               capture_output=True, text=True)
        return bool(result.stdout.strip())
    except:
        return False

def check_llama_server():
    """Cek apakah llama-server berjalan."""
    try:
        result = subprocess.run(["pgrep", "-f", "llama-server"], 
                               capture_output=True, text=True)
        return bool(result.stdout.strip())
    except:
        return False

def restart_service(service_name):
    """Restart service dengan aman."""
    if service_name == "supervisor":
        subprocess.run(["nohup", "bash", 
                       os.path.join(JDEQ, "supervisor_jdeq.sh"), "&"], 
                      capture_output=True)
        log_recovery("SUPERVISOR_RESTART", "Manual restart", "ATTEMPTED")
        return True
    return False

def run_recovery_check():
    """Jalankan pengecekan dan recovery."""
    print("[RECOVERY] Memeriksa status layanan...")
    
    # 1. Cek supervisor
    spv_ok = check_supervisor()
    print(f"[RECOVERY] Supervisor: {'AKTIF' if spv_ok else 'MATI'}")
    if not spv_ok:
        log_recovery("SUPERVISOR_DOWN", "Tidak ada supervisor", "WARNING")
        # Jangan auto-restart tanpa approval (Phase 20)
        print("[RECOVERY] ⚠️  Restart butuh persetujuan Mas Iswan")
    
    # 2. Cek llama-server
    llama_ok = check_llama_server()
    print(f"[RECOVERY] llama-server: {'AKTIF' if llama_ok else 'MATI'}")
    if not llama_ok:
        log_recovery("LLAMA_DOWN", "llama-server tidak berjalan", "WARNING")
    
    # 3. Cek disk space
    stat = os.statvfs(JDEQ)
    free_pct = (stat.f_bavail / stat.f_blocks) * 100 if stat.f_blocks else 0
    print(f"[RECOVERY] Disk free: {free_pct:.1f}%")
    if free_pct < 10:
        log_recovery("DISK_LOW", f"Disk free {free_pct:.1f}%", "WARNING")
    
    # 4. Cek decision log tidak kosong
    dec_log = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.json")
    if os.path.isfile(dec_log):
        with open(dec_log) as f:
            data = json.load(f)
        print(f"[RECOVERY] Decision log: {len(data)} keputusan")
        if len(data) > 100:
            log_recovery("DECISION_LOG_BESAR", f"{len(data)} entries", "INFO")
    
    log_recovery("RECOVERY_CHECK_COMPLETE", "Semua cek selesai", "PASS")
    print("[RECOVERY] Pengecekan selesai")

if __name__ == "__main__":
    run_recovery_check()
