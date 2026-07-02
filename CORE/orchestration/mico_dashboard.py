import os, json

JDEQ = "/data/data/com.termux/files/home/JDEQ"

def dashboard():
    print("="*50)
    print("  MICO STATUS DASHBOARD")
    print("="*50)
    # Core
    print("CORE     : ONLINE")
    # SSOT
    ssot = "OK" if os.path.isdir(os.path.join(JDEQ,"SSOT")) else "FAIL"
    print(f"SSOT     : {ssot}")
    # Memory
    audit = "OK" if os.path.isfile(os.path.join(JDEQ,"CORE_MEMORY/logs/audit.log")) else "FAIL"
    print(f"MEMORY   : {audit}")
    # Agent
    ag_path = os.path.join(JDEQ,"ORCHESTRATOR/AGENT_REGISTRY.json")
    if os.path.isfile(ag_path):
        with open(ag_path) as f:
            ag = json.load(f)
        aktif = [a['id'] for a in ag['agents'] if a['status']=='aktif']
        print(f"AGENT    : {len(aktif)} ACTIVE ({', '.join(aktif[:3])}...)")
    # Event
    ev_log = os.path.join(JDEQ,"CORE_MEMORY/logs/event.log")
    event = "RUNNING" if os.path.isfile(ev_log) else "IDLE"
    print(f"EVENT    : {event}")
    # Recovery
    spv = "READY" if os.path.isfile(os.path.join(JDEQ,"supervisor_jdeq.sh")) else "FAIL"
    print(f"RECOVERY : {spv}")
    # Environment
    from environment_engine import get_env_info
    env = get_env_info()
    print(f"OS       : {env['os']} | Python {env['python'].split()[0]}")
    print("="*50)

if __name__ == "__main__":
    dashboard()
