import json, os

JDEQ = "/data/data/com.termux/files/home/JDEQ"
STATUS_FILE = os.path.join(JDEQ, "ORCHESTRATOR/status.json")

def update_status(component, state):
    status = {}
    if os.path.exists(STATUS_FILE):
        with open(STATUS_FILE) as f:
            status = json.load(f)
    status[component] = state
    with open(STATUS_FILE, "w") as f:
        json.dump(status, f, indent=2)

def get_status():
    if os.path.exists(STATUS_FILE):
        with open(STATUS_FILE) as f:
            return json.load(f)
    return {}
