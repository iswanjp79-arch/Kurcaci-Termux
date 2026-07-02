#!/usr/bin/env python3
import json, sys, time
from pathlib import Path

VAULT = Path.home() / "JDEQ" / "vault" / "api_keys.json"

def load():
    return json.loads(VAULT.read_text())

def save(data):
    VAULT.write_text(json.dumps(data, indent=2))

def rotate(service):
    data = load()
    keys = data.get(service, [])
    if not keys:
        return ""
    fresh = [k for k in keys if k.get("status") != "used"]
    if not fresh:
        for k in keys:
            k["status"] = "free"
        fresh = keys
    key = fresh[0]
    key["status"] = "used"
    key["last_used"] = time.time()
    save(data)
    return key["key"]

if __name__ == "__main__":
    if len(sys.argv) > 1:
        print(rotate(sys.argv[1]))
    else:
        # default: gemini
        print(rotate("gemini"))
