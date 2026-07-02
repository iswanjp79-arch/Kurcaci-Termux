#!/usr/bin/env python3
import json, os, time
from datetime import datetime
LEARN_LOG = os.path.expanduser("~/JDEQ/logs/learning.jsonl")
def learn(event, outcome):
    entry = {"time": str(datetime.now()), "event": event, "outcome": outcome}
    with open(LEARN_LOG, "a") as f: f.write(json.dumps(entry) + "\n")
    return entry
if __name__ == "__main__":
    print(json.dumps(learn("system_boot", "success")))
