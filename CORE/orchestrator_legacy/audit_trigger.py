import os
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
AUDIT_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/audit.log")

def auto_audit(event, detail):
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(AUDIT_LOG, "a") as f:
        f.write(f"[{ts}] AUDIT_TRIGGER [{event}] [{detail}]\n")
