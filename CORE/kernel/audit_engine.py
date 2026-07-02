#!/usr/bin/env python3
import json, os, hashlib, sys
from datetime import datetime
AUDIT_LOG = os.path.expanduser("~/JDEQ/logs/audit_trail.jsonl")
def audit(event, data=""):
    entry = {"time": str(datetime.now()), "event": event, "hash": hashlib.sha256(data.encode()).hexdigest()[:16]}
    with open(AUDIT_LOG, "a") as f: f.write(json.dumps(entry) + "\n")
    return entry
if __name__ == "__main__":
    print(json.dumps(audit(" ".join(sys.argv[1:]) if len(sys.argv) > 1 else "system_check")))
