import os, json, subprocess
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
AUDIT = os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")

def log(level, msg):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(AUDIT, "a") as f:
        f.write(f"[{ts}] AUTOMATION [{level}] {msg}\n")
    print(f"[AUTOMATION] [{level}] {msg}")

def check_approval(action):
    """Cek Approval Gate (import dari CORE_ORCHESTRATION)."""
    try:
        import sys
        sys.path.insert(0, os.path.join(JDEQ, "CORE_ORCHESTRATION"))
        from approval_gate import gate_check
        return gate_check(action, "Automation Request")
    except Exception as e:
        log("ERROR", f"Approval Gate gagal: {e}")
        return False  # Gagal aman

def execute_action(action):
    """Eksekusi aksi yang sudah disetujui."""
    actions_map = {
        "generate_report": os.path.join(JDEQ, "PROJECT_CONTROL/PEP/generate_pep.py"),
        "run_dashboard": os.path.join(JDEQ, "CORE_ORCHESTRATION/mico_dashboard.py"),
        "health_check": os.path.join(JDEQ, "CORE_ORCHESTRATION/health_scheduler.py"),
    }
    
    if action not in actions_map:
        log("HOLD", f"Aksi '{action}' tidak dikenal")
        return False
    
    script = actions_map[action]
    if not os.path.isfile(script):
        log("HOLD", f"Script '{script}' tidak ditemukan")
        return False
    
    try:
        subprocess.run(["python3", script], check=True, capture_output=True, text=True, timeout=30)
        log("PASS", f"Aksi '{action}' berhasil")
        return True
    except subprocess.TimeoutExpired:
        log("FAIL", f"Aksi '{action}' timeout (30s)")
        return False
    except subprocess.CalledProcessError as e:
        log("FAIL", f"Aksi '{action}' gagal: {e}")
        return False

def automation_engine(action_request, auto_execute=False):
    """Mesin otomatisasi terkendali."""
    print("\n[MICO AUTOMATION]")
    print(f"  Permintaan : {action_request}")
    
    # 1. Cek Approval
    approved = check_approval(action_request)
    
    if not approved:
        log("WAIT", f"'{action_request}' butuh persetujuan Mas Iswan")
        return {"status": "WAIT_APPROVAL", "action": action_request}
    
    # 2. Eksekusi (jika AUTO atau sudah disetujui)
    if auto_execute:
        success = execute_action(action_request)
        status = "EXECUTED" if success else "FAILED"
    else:
        status = "APPROVED_BUT_NOT_EXECUTED"
    
    log("COMPLETE", f"'{action_request}' status: {status}")
    return {"status": status, "action": action_request}
