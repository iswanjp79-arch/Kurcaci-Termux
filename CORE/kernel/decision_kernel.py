#!/usr/bin/env python3
import json, os, time, sys
from datetime import datetime
LOG = os.path.expanduser("~/JDEQ/logs/decisions.jsonl")
def decide(context):
    decision = {"time": str(datetime.now()), "context": context, "action": "MONITOR"}
    with open(LOG, "a") as f: f.write(json.dumps(decision) + "\n")
    return decision
if __name__ == "__main__":
    print(json.dumps(decide(" ".join(sys.argv[1:]) if len(sys.argv) > 1 else "system_check")))
