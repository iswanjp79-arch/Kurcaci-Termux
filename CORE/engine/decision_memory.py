import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
DECISION_LOG = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.json")
DECISION_MD = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.md")

def catat_keputusan(event, decision, reason, result):
    """Catat keputusan MICO dengan format JSON."""
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    entry = {
        "time": ts,
        "event": event,
        "decision": decision,
        "reason": reason,
        "result": result
    }
    # JSON log
    data = []
    if os.path.isfile(DECISION_LOG):
        with open(DECISION_LOG) as f:
            data = json.load(f)
    data.append(entry)
    with open(DECISION_LOG, "w") as f:
        json.dump(data, f, indent=2)
    # Markdown log (human readable)
    with open(DECISION_MD, "a") as f:
        f.write(f"| {ts} | {event} | {decision} | {reason} | {result} |\n")
    print(f"[DECISION] {event} → {decision} ({result})")

if __name__ == "__main__":
    # Test
    catat_keputusan("PHASE14_TEST", "UPGRADE_DECISION_MEMORY", "Format JSON untuk histori", "SUCCESS")
