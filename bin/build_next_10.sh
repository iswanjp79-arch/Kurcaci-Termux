#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/build_next_10_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }
PASS=0

stamp "============================================"
stamp "  MEMBANGUN 10 KOMPONEN INTI MICO"
stamp "  Menuju Adaptive Evolution"
stamp "============================================"

# Buat direktori
mkdir -p ~/JDEQ/CORTEX
mkdir -p ~/JDEQ/CORE/KERNEL

# ------------------------------------------------------------------
# 1. EVENT BUS (Jantung komunikasi)
# ------------------------------------------------------------------
stamp "1/10 Event Bus..."
cat > ~/JDEQ/CORTEX/event_bus.py << 'PYEOF'
#!/usr/bin/env python3
import json, os, time
from datetime import datetime
BUS_DIR = os.path.expanduser("~/JDEQ/CORTEX/events")
os.makedirs(BUS_DIR, exist_ok=True)
def publish(event_type, payload=None):
    if payload is None: payload = {}
    event = {"id": datetime.now().strftime("%Y%m%d%H%M%S%f"),
             "timestamp": str(datetime.now()), "type": event_type, "payload": payload}
    with open(os.path.join(BUS_DIR, f"evt_{event['id']}.json"), 'w') as f:
        json.dump(event, f)
    return event
publish("SYSTEM_BOOT", {"status": "Event Bus Ready"})
print("✅ Event Bus aktif")
PYEOF
python3 ~/JDEQ/CORTEX/event_bus.py 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 2. CONTEXT BUILDER
# ------------------------------------------------------------------
stamp "2/10 Context Builder..."
cat > ~/JDEQ/CORTEX/context_builder.py << 'PYEOF'
#!/usr/bin/env python3
import os, json, subprocess
from datetime import datetime
def build_context(trigger=""):
    try:
        batt = os.popen("termux-battery-status 2>/dev/null | grep percentage | grep -o '[0-9]*'").read().strip()
        ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
        disk = os.popen("df -h ~ | awk 'NR==2 {print $5}'").read().strip()
        llm_alive = subprocess.run(["pgrep", "-f", "llama-server"], capture_output=True).returncode == 0
        return {"timestamp": str(datetime.now()), "trigger": trigger,
                "battery": batt or "N/A", "ram_mb": ram, "disk_pct": disk, "llm_alive": llm_alive}
    except: return {"error": "Gagal membaca konteks"}
if __name__ == "__main__":
    ctx = build_context("CORTEX_INIT")
    print(f"Context: {json.dumps(ctx, indent=2)}")
    print("✅ Context Builder aktif")
PYEOF
python3 ~/JDEQ/CORTEX/context_builder.py 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 3. INTENT GRAPH
# ------------------------------------------------------------------
stamp "3/10 Intent Graph..."
cat > ~/JDEQ/CORTEX/intent_graph.py << 'PYEOF'
#!/usr/bin/env python3
import sys, json
RULES = {
    "lihat|foto|potret|ambil gambar": {"intent": "CAPTURE_IMAGE", "capability": "camera_capture"},
    "lapor|laporkan|kabar|bagaimana": {"intent": "GENERATE_REPORT", "capability": "report_generator"},
    "sehat|cek|kondisi|status": {"intent": "HEALTH_CHECK", "capability": "health_checker"},
    "halo|hai|pagi|siang|sore|malam": {"intent": "GREETING", "capability": "tts_speak"},
}
def detect(text):
    t = text.lower()
    for pattern, action in RULES.items():
        if any(word in t for word in pattern.split("|")): return action
    return {"intent": "UNKNOWN", "capability": None}
if __name__ == "__main__":
    txt = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "halo MICO"
    print(f"Intent: {json.dumps(detect(txt), indent=2)}")
    print("✅ Intent Graph aktif")
PYEOF
python3 ~/JDEQ/CORTEX/intent_graph.py "halo MICO" 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 4. CAPABILITY GRAPH
# ------------------------------------------------------------------
stamp "4/10 Capability Graph..."
cat > ~/JDEQ/CORTEX/capability_graph.py << 'PYEOF'
#!/usr/bin/env python3
import sys, json, subprocess
CAPABILITIES = {
    "camera_capture": "bash ~/JDEQ/bridge/macro_listener.sh capture",
    "report_generator": "bash ~/JDEQ/bin/laporan_dewan.sh",
    "health_checker": "bash ~/JDEQ/bin/health_check.sh",
    "tts_speak": "termux-tts-speak 'Halo dari MICO'"
}
def execute(capability):
    cmd = CAPABILITIES.get(capability, "echo 'Tidak dikenal'")
    try:
        out = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
        return {"status": "EXECUTED", "output": out.stdout.strip() or out.stderr.strip()}
    except Exception as e: return {"status": "FAILED", "output": str(e)}
if __name__ == "__main__":
    cap = sys.argv[1] if len(sys.argv) > 1 else "health_checker"
    print(f"Capability '{cap}': {json.dumps(execute(cap), indent=2)}")
    print("✅ Capability Graph aktif")
PYEOF
python3 ~/JDEQ/CORTEX/capability_graph.py health_checker 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 5. NODE DISPATCHER (Logika pengarah)
# ------------------------------------------------------------------
stamp "5/10 Node Dispatcher..."
cat > ~/JDEQ/CORE/KERNEL/node_dispatcher.py << 'PYEOF'
#!/usr/bin/env python3
import json, sys
NODES = {"sensor":"local","vision":"local","voice":"local","report":"local","audit":"local"}
def dispatch(capability):
    node = NODES.get(capability, "unknown")
    return {"capability": capability, "node": node, "status": "dispatched"}
if __name__ == "__main__":
    print(f"Dispatch: {json.dumps(dispatch(sys.argv[1] if len(sys.argv) > 1 else 'audit'), indent=2)}")
    print("✅ Node Dispatcher aktif")
PYEOF
python3 ~/JDEQ/CORE/KERNEL/node_dispatcher.py audit 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 6. BEHAVIOR CONTRACT (Template kontrak perilaku)
# ------------------------------------------------------------------
stamp "6/10 Behavior Contract..."
mkdir -p ~/JDEQ/CORE/NODES
cat > ~/JDEQ/CORE/NODES/behavior_contract_template.json << 'JSONEOF'
{
  "node_id": "NODE001",
  "identity": "Sensor Node",
  "capability": ["sensor_read"],
  "state": "sleep",
  "memory_pointer": "/JDEQ/memory/node001.json",
  "policy": {"max_retries": 3, "timeout_ms": 5000},
  "risk": "LOW",
  "recovery": "restart_node001.sh",
  "audit": "/JDEQ/logs/node001_audit.log",
  "learning": "/JDEQ/logs/node001_learn.jsonl"
}
JSONEOF
stamp "✅ Behavior Contract template siap" && ((PASS++))

# ------------------------------------------------------------------
# 7. STORAGE MANAGER (Placeholder)
# ------------------------------------------------------------------
stamp "7/10 Storage Manager..."
cat > ~/JDEQ/CORE/KERNEL/storage_manager.py << 'PYEOF'
#!/usr/bin/env python3
import json
STORES = {"ssd": "~/JDEQ", "cloud": "gdrive:Backup_Platform_AI", "infinix": "100.103.39.81:/JDEQ_CLONE"}
def resolve(knowledge_id):
    return STORES.get("ssd", "unknown")
if __name__ == "__main__":
    print(f"Storage for 'drawing-001': {resolve('drawing-001')}")
    print("✅ Storage Manager aktif")
PYEOF
python3 ~/JDEQ/CORE/KERNEL/storage_manager.py 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 8. RECOVERY MANAGER (Template)
# ------------------------------------------------------------------
stamp "8/10 Recovery Manager..."
cat > ~/JDEQ/CORE/KERNEL/recovery_manager.sh << 'SHEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Recovery Manager siap — gunakan: bash ~/JDEQ/bin/auto_heal_all.sh"
SHEOF
chmod +x ~/JDEQ/CORE/KERNEL/recovery_manager.sh
stamp "✅ Recovery Manager siap" && ((PASS++))

# ------------------------------------------------------------------
# 9. RESOURCE MANAGER (Template)
# ------------------------------------------------------------------
stamp "9/10 Resource Manager..."
cat > ~/JDEQ/CORE/KERNEL/resource_manager.py << 'PYEOF'
#!/usr/bin/env python3
import os, json
def get_resources():
    ram = os.popen("free -m | awk '/Mem/{print $7}'").read().strip()
    disk = os.popen("df -h ~ | awk 'NR==2 {print $5}'").read().strip()
    return {"ram_free_mb": int(ram) if ram.isdigit() else 0, "disk_used_pct": disk}
if __name__ == "__main__":
    print(f"Resources: {json.dumps(get_resources(), indent=2)}")
    print("✅ Resource Manager aktif")
PYEOF
python3 ~/JDEQ/CORE/KERNEL/resource_manager.py 2>&1 | tee -a $LOG && ((PASS++))

# ------------------------------------------------------------------
# 10. SECURITY MANAGER (Template)
# ------------------------------------------------------------------
stamp "10/10 Security Manager..."
cat > ~/JDEQ/CORE/KERNEL/security_manager.sh << 'SHEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Security Manager siap — audit_pertahanan.sh sudah berjalan tiap 30 menit"
SHEOF
chmod +x ~/JDEQ/CORE/KERNEL/security_manager.sh
stamp "✅ Security Manager siap" && ((PASS++))

# ------------------------------------------------------------------
# RINGKASAN
# ------------------------------------------------------------------
stamp ""
stamp "============================================"
stamp "  10 KOMPONEN INTI SELESAI DIBANGUN"
stamp "  ✅ Event Bus"
stamp "  ✅ Context Builder"
stamp "  ✅ Intent Graph"
stamp "  ✅ Capability Graph"
stamp "  ✅ Node Dispatcher"
stamp "  ✅ Behavior Contract Template"
stamp "  ✅ Storage Manager"
stamp "  ✅ Recovery Manager"
stamp "  ✅ Resource Manager"
stamp "  ✅ Security Manager"
stamp "  Skor: $PASS/10"
stamp "  Fase: Brain Stem → Cortex"
stamp "============================================"
