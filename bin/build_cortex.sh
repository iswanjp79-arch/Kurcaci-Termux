#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/cortex_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }
CORTEX_DIR="$HOME/JDEQ/CORTEX"
mkdir -p $CORTEX_DIR

stamp "============================================"
stamp "  MEMBANGUN MICO CORTEX (BATANG OTAK → OTAK)"
stamp "============================================"

# 1. EVENT BUS — Jantung komunikasi antar modul
cat > $CORTEX_DIR/event_bus.py << 'PYEOF'
#!/usr/bin/env python3
import json, os, time
from datetime import datetime
from pathlib import Path

BUS_DIR = Path.home() / "JDEQ/CORTEX/events"
BUS_DIR.mkdir(parents=True, exist_ok=True)

def publish(event_type, payload):
    event = {"timestamp": str(datetime.now()), "type": event_type, "payload": payload}
    event_file = BUS_DIR / f"{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}.json"
    event_file.write_text(json.dumps(event))
    return event

if __name__ == "__main__":
    publish("SYSTEM_BOOT", {"status": "CORTEX_BUILDING"})
    print("✅ Event Bus aktif")
PYEOF

# 2. CONTEXT BUILDER — Memahami situasi sekitar
cat > $CORTEX_DIR/context_builder.py << 'PYEOF'
#!/usr/bin/env python3
import json, os, subprocess
from datetime import datetime

def build_context(trigger=""):
    context = {
        "timestamp": str(datetime.now()),
        "trigger": trigger,
        "battery": os.popen("termux-battery-status 2>/dev/null | grep percentage | grep -o '[0-9]*'").read().strip() or "N/A",
        "ram_mb": os.popen("free -m | awk '/Mem/{print $7}'").read().strip(),
        "disk_pct": os.popen("df -h ~ | awk 'NR==2 {print $5}'").read().strip(),
        "llm_alive": subprocess.run(["pgrep", "-f", "llama-server"], capture_output=True).returncode == 0
    }
    return context

if __name__ == "__main__":
    ctx = build_context("CORTEX_INIT")
    print(f"Context: {json.dumps(ctx, indent=2)}")
    print("✅ Context Builder aktif")
PYEOF

# Jalankan modul Cortex
python3 $CORTEX_DIR/event_bus.py 2>&1 | tee -a $LOG
python3 $CORTEX_DIR/context_builder.py 2>&1 | tee -a $LOG

stamp "============================================"
stamp "  MICO CORTEX AKTIF"
stamp "  - Event Bus: Jalan"
stamp "  - Context Builder: Jalan"
stamp "  Ini adalah langkah menuju 'Cortex'"
stamp "============================================"
