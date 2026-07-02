import os, sys, subprocess
JDEQ = "/data/data/com.termux/files/home/JDEQ"
sys.path.insert(0, JDEQ)

def run_module(module, *args):
    script_map = {
        "rab": f"{JDEQ}/PROJECT_CONTROL/rab_engine.py",
        "cpm": f"{JDEQ}/PROJECT_CONTROL/orchestrator.py",
        "evm": f"{JDEQ}/PROJECT_CONTROL/evm_engine.py",
        "dashboard": f"{JDEQ}/CORE_ORCHESTRATION/mico_dashboard.py",
        "security": f"{JDEQ}/CORE_SECURITY/security_hardening.py",
        "recovery": f"{JDEQ}/CORE_SECURITY/recovery_manager.py",
    }
    if module in script_map:
        subprocess.run(["python3", script_map[module]], check=True)

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        run_module(cmd)
    else:
        print("[MICO] Unified Agent siap.")
