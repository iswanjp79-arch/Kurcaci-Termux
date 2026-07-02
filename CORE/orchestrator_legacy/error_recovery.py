import os, json

JDEQ = "/data/data/com.termux/files/home/JDEQ"
RECOVERY_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/recovery.log")

def recovery_action(agent):
    """Tindakan pemulihan jika agen gagal."""
    from datetime import datetime
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(RECOVERY_LOG, "a") as f:
        f.write(f"[{ts}] RECOVERY [{agent}] [RESTART ATTEMPT]\n")
    # Logika pemulihan sederhana: catat dan beri tahu orchestrator
    return True
