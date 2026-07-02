import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"

def link_event_to_decision():
    """Hubungkan event terakhir ke decision memory."""
    event_log = os.path.join(JDEQ, "CORE_MEMORY/logs/event.log")
    decision_log = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.json")
    md_log = os.path.join(JDEQ, "CORE_MEMORY/logs/decision_memory.md")
    
    if not os.path.isfile(event_log):
        print("[LINK] Event log belum ada")
        return
    
    # Baca event terakhir
    with open(event_log) as f:
        lines = f.readlines()
    if not lines:
        print("[LINK] Event log kosong")
        return
    
    last_event = lines[-1].strip()
    # Parse event: [timestamp] EVENT [event] ACTION [action] RESULT [result]
    ts_str = last_event.split("]")[0].replace("[", "")
    try:
        event_part = last_event.split("EVENT [")[1].split("]")[0]
        action_part = last_event.split("ACTION [")[1].split("]")[0]
        result_part = last_event.split("RESULT [")[1].split("]")[0]
    except IndexError:
        print("[LINK] Format event ora dikenal")
        return
    
    # Catat keputusan otomatis
    entry = {
        "time": ts_str,
        "event": event_part,
        "decision": action_part,
        "reason": f"Auto-response from Event Bridge",
        "result": result_part
    }
    
    # JSON log
    data = []
    if os.path.isfile(decision_log):
        with open(decision_log) as f:
            data = json.load(f)
    data.append(entry)
    with open(decision_log, "w") as f:
        json.dump(data, f, indent=2)
    
    # Markdown log
    header_written = os.path.isfile(md_log) and os.path.getsize(md_log) > 0
    with open(md_log, "a") as f:
        if not header_written:
            f.write("| Time | Event | Decision | Reason | Result |\n")
            f.write("|------|-------|----------|--------|--------|\n")
        f.write(f"| {ts_str} | {event_part} | {action_part} | Auto-response | {result_part} |\n")
    
    print(f"[LINK] Event '{event_part}' → Decision recorded")

if __name__ == "__main__":
    link_event_to_decision()
