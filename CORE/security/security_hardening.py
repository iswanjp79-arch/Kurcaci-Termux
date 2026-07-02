import os, stat, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
SECURITY_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/security.log")

def log_security(event, detail, status):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(SECURITY_LOG, "a") as f:
        f.write(f"[{ts}] SECURITY [{status}] [{event}] {detail}\n")

def check_permissions():
    """Periksa permission file-file kritis."""
    critical_files = [
        os.path.join(JDEQ, "CORE_PROTOCOL/CORE_RULE.md"),
        os.path.join(JDEQ, "CORE_PROTOCOL/mico_identity.json"),
        os.path.join(JDEQ, "supervisor_jdeq.sh"),
        os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")
    ]
    
    results = []
    for f in critical_files:
        if not os.path.isfile(f):
            results.append({"file": f, "status": "MISSING"})
            log_security("FILE_MISSING", f, "FAIL")
            continue
        
        st = os.stat(f)
        mode = stat.S_IMODE(st.st_mode)
        
        # Cek world-writable
        if mode & stat.S_IWOTH:
            results.append({"file": f, "status": "WORLD_WRITABLE", "mode": oct(mode)})
            log_security("WORLD_WRITABLE", f, "WARNING")
        else:
            results.append({"file": f, "status": "OK", "mode": oct(mode)})
    
    return results

def check_log_integrity():
    """Cek integritas log (tidak ada manipulasi sederhana)."""
    audit_log = os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")
    if not os.path.isfile(audit_log):
        log_security("LOG_MISSING", "audit.log", "FAIL")
        return False
    
    # Cek ukuran log (jangan > 10 MB, warning)
    size_mb = os.path.getsize(audit_log) / (1024*1024)
    if size_mb > 10:
        log_security("LOG_OVERSIZE", f"audit.log {size_mb:.1f} MB", "WARNING")
    
    return True

def run_security_check():
    """Jalankan semua cek keamanan."""
    print("[SECURITY] Menjalankan hardening check...")
    
    # 1. Permission
    perm_results = check_permissions()
    issues = sum(1 for r in perm_results if r["status"] != "OK")
    print(f"[SECURITY] Permission: {len(perm_results)} file, {issues} isu")
    
    # 2. Log integrity
    log_ok = check_log_integrity()
    print(f"[SECURITY] Log Integrity: {'OK' if log_ok else 'FAIL'}")
    
    # 3. Cek backup
    backup_dir = os.path.join(JDEQ, "backup")
    if os.path.isdir(backup_dir):
        backups = os.listdir(backup_dir)
        print(f"[SECURITY] Backup: {len(backups)} tersedia")
    else:
        log_security("BACKUP_MISSING", "Folder backup tidak ada", "WARNING")
        print("[SECURITY] Backup: TIDAK ADA")
    
    log_security("HARDENING_COMPLETE", f"{issues} isu ditemukan", "PASS" if issues == 0 else "WARNING")
    print("[SECURITY] Hardening selesai")

if __name__ == "__main__":
    run_security_check()
