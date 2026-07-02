#!/data/data/com.termux/files/usr/bin/python3
# JDEQ Executive Loop – Final Version

import os, json, time, subprocess
HOME = os.path.expanduser("~")
CONFIG_DIR = os.path.join(HOME, "JDEQ/config")
LOG_DIR = os.path.join(HOME, "JDEQ/logs")

def load_json(file):
    try:
        with open(file, "r") as f:
            return json.load(f)
    except:
        return {}

def write_state_to_memory(state):
    try:
        with open(os.path.join(CONFIG_DIR, "memory.json"), "r") as f:
            memory = json.load(f)
        if "system_state" not in memory:
            memory["system_state"] = []
    except:
        memory = {"system_state": []}
    memory["system_state"].append({"timestamp": time.time(), "state": state})
    if len(memory["system_state"]) > 100:
        memory["system_state"] = memory["system_state"][-100:]
    with open(os.path.join(CONFIG_DIR, "memory.json"), "w") as f:
        json.dump(memory, f, indent=2)

def observe():
    return {
        "state": load_json(os.path.join(CONFIG_DIR, "state.json")),
        "goals": load_json(os.path.join(CONFIG_DIR, "goals.json")),
        "identity": load_json(os.path.join(CONFIG_DIR, "identity.json"))
    }

def orient(data):
    return "lanjutkan_ke_P4" if data["state"].get("fase_aktif") == "P3" else "stabil"

def decide(orientation):
    if orientation == "lanjutkan_ke_P4":
        return {"action": "update_state", "new_state": {"fase_aktif": "P4"}}
    return {"action": "wait"}

def act(decision):
    if decision["action"] == "update_state":
        state = load_json(os.path.join(CONFIG_DIR, "state.json"))
        state.update(decision["new_state"])
        with open(os.path.join(CONFIG_DIR, "state.json"), "w") as f:
            json.dump(state, f, indent=2)
        print("✅ State updated to P4")
        return state
    print("⏳ Waiting...")
    return None

def learn():
    with open(os.path.join(LOG_DIR, "executive_loop.log"), "a") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Loop executed\n")

def main():
    last_write, dirty = 0, False
    while True:
        data = observe()
        new_state = act(decide(orient(data)))
        learn()
        if new_state is not None:
            dirty = True
        if time.time() - last_write > 900 or dirty:
            write_state_to_memory(data)
            last_write, dirty = time.time(), False
        time.sleep(60)
        # Auto-Throttle setiap 10 menit

        if int(time.time()) % 600 == 0:

            subprocess.run(["/data/data/com.termux/files/home/JDEQ/bin/mico_throttle.sh"], capture_output=True)
        # Health check setiap 5 menit

        if int(time.time()) % 300 == 0:

            subprocess.run(["/data/data/com.termux/files/home/JDEQ/bin/mico_health.sh"], capture_output=True)
        # AutoCare: optimize setiap 24 jam (86400 detik)

        if int(time.time()) % 86400 < 60:

            import subprocess

            subprocess.run(["/data/data/com.termux/files/home/JDEQ/bin/mico_optimize.sh"], capture_output=True)

            with open("/data/data/com.termux/files/home/JDEQ/logs/executive_loop.log", "a") as f:

                f.write(f"{time.strftime("%Y-%m-%d %H:%M:%S")} - AutoCare executed\n")

if __name__ == "__main__":
    main()
