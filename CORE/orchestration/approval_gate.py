import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
GATE_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/approval_gate.log")

def approval_level(action):
    """Tentukan level approval."""
    AUTO = ["generate_report", "run_checklist", "update_dashboard"]
    NOTIFY = ["update_rab", "update_evm", "modify_schedule"]
    HIGH = ["delete_data", "change_blueprint", "change_security"]
    
    if action in AUTO:
        return "AUTO"
    elif action in NOTIFY:
        return "NOTIFY"
    elif action in HIGH:
        return "WAIT"
    return "NOTIFY"  # default aman

def gate_check(action, detail):
    level = approval_level(action)
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(GATE_LOG, "a") as f:
        f.write(f"[{ts}] GATE [{action}] LEVEL [{level}] DETAIL [{detail}]\n")
    
    if level == "AUTO":
        print(f"[GATE] AUTO: {action} langsung dijalankan")
        return True
    elif level == "NOTIFY":
        print(f"[GATE] NOTIFY: {action} dijalankan, Mas Iswan diberi tahu")
        return True
    elif level == "WAIT":
        print(f"[GATE] WAIT: {action} butuh persetujuan Mas Iswan")
        return False
    return False

if __name__ == "__main__":
    gate_check("generate_report", "Test approval gate V2")
