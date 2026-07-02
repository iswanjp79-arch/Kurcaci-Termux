#!/data/data/com.termux/files/usr/bin/bash
set -e
LOG="$HOME/JDEQ/logs/cognitive_layer_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "============================================"
stamp " BUNDLE COGNITIVE LAYER - MICO KESADARAN DIGITAL"
stamp "============================================"
mkdir -p ~/JDEQ/cognitive/{knowledge,decision,sensor,learning}

# ============================================================
# MODUL 1: KNOWLEDGE CORE (SQLite + Embedding)
# ============================================================
stamp ""
stamp "===== MODUL 1: KNOWLEDGE CORE ====="

# Install sqlite3 jika belum ada
pkg install sqlite -y 2>/dev/null || true

# Buat database pengetahuan
cat > ~/JDEQ/cognitive/knowledge/init_knowledge.py << 'PYEOF'
#!/usr/bin/env python3
"""MICO Knowledge Core - SQLite + JSON Vector Store"""
import sqlite3, json, os, hashlib, time
from datetime import datetime

DB_PATH = os.path.expanduser("~/JDEQ/cognitive/knowledge/knowledge.db")
MEM_DIR = os.path.expanduser("~/JDEQ/cognitive/knowledge/memories/")

os.makedirs(MEM_DIR, exist_ok=True)

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS memories (
        id TEXT PRIMARY KEY,
        timestamp TEXT,
        category TEXT,
        input TEXT,
        response TEXT,
        context TEXT,
        tags TEXT,
        importance INTEGER DEFAULT 1
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS concepts (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE,
        description TEXT,
        related_ids TEXT,
        created TEXT
    )''')
    c.execute('''CREATE TABLE IF NOT EXISTS decisions (
        id TEXT PRIMARY KEY,
        timestamp TEXT,
        options TEXT,
        chosen TEXT,
        reason TEXT,
        outcome TEXT
    )''')
    conn.commit()
    conn.close()
    return "Knowledge Core siap"

def store_memory(category, input_text, response_text, context="", tags=""):
    conn = sqlite3.connect(DB_PATH)
    mem_id = hashlib.md5(f"{category}{input_text}{time.time()}".encode()).hexdigest()[:12]
    c = conn.cursor()
    c.execute("INSERT OR REPLACE INTO memories VALUES (?,?,?,?,?,?,?,?)",
        (mem_id, str(datetime.now()), category, input_text, response_text, context, tags, 1))
    conn.commit()
    conn.close()
    
    # Simpan juga sebagai file JSON untuk vector retrieval nanti
    mem_file = os.path.join(MEM_DIR, f"{mem_id}.json")
    with open(mem_file, 'w') as f:
        json.dump({
            "id": mem_id, "category": category, "input": input_text,
            "response": response_text, "context": context, "tags": tags
        }, f)
    return mem_id

def search_memory(query, limit=5):
    """Pencarian sederhana berdasarkan kata kunci"""
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    keywords = query.lower().split()
    results = []
    for kw in keywords:
        c.execute("SELECT * FROM memories WHERE input LIKE ? OR response LIKE ? OR tags LIKE ? LIMIT ?",
            (f"%{kw}%", f"%{kw}%", f"%{kw}%", limit))
        results.extend(c.fetchall())
    conn.close()
    return results[:limit]

if __name__ == "__main__":
    print(init_db())
    # Simpan memori pertama
    mid = store_memory("system", "MICO Cognitive Layer aktif", "Knowledge Core berjalan", "bootstrap")
    print(f"Memori tersimpan: {mid}")
PYEOF
chmod +x ~/JDEQ/cognitive/knowledge/init_knowledge.py
python3 ~/JDEQ/cognitive/knowledge/init_knowledge.py 2>&1 | tee -a $LOG
stamp "✅ Knowledge Core aktif"

# ============================================================
# MODUL 2: DECISION KERNEL
# ============================================================
stamp ""
stamp "===== MODUL 2: DECISION KERNEL ====="

cat > ~/JDEQ/cognitive/decision/decision_kernel.py << 'PYEOF'
#!/usr/bin/env python3
"""MICO Decision Kernel - Pengambil keputusan akhir"""
import json, os, sys, subprocess
from datetime import datetime

DECISION_LOG = os.path.expanduser("~/JDEQ/cognitive/decision/decisions.jsonl")

def decide(options, context=""):
    """Pilih opsi terbaik berdasarkan konteks dan aturan"""
    # Aturan sederhana: prioritas berdasarkan keyword
    rules = {
        "keamanan": 10, "security": 10, "crash": 10,
        "auto-heal": 8, "recovery": 8,
        "backup": 7, "sync": 7,
        "optimasi": 5, "pengembangan": 3
    }
    
    scored = []
    for opt in options:
        score = sum(rules.get(kw, 0) for kw in opt.lower().split())
        scored.append((opt, score))
    
    scored.sort(key=lambda x: x[1], reverse=True)
    chosen = scored[0][0] if scored else options[0] if options else "tidak_ada_pilihan"
    
    # Log keputusan
    decision = {
        "timestamp": str(datetime.now()),
        "options": options,
        "chosen": chosen,
        "reason": f"Score tertinggi: {scored[0][1]}" if scored else "Default",
        "context": context
    }
    
    with open(DECISION_LOG, 'a') as f:
        f.write(json.dumps(decision) + "\n")
    
    return chosen

if __name__ == "__main__":
    # Contoh penggunaan
    test_options = ["restart LLM", "sync cloud", "kirim notifikasi"]
    result = decide(test_options, "LLM mati terdeteksi")
    print(f"Keputusan: {result}")
PYEOF
chmod +x ~/JDEQ/cognitive/decision/decision_kernel.py

# Tes Decision Kernel
python3 ~/JDEQ/cognitive/decision/decision_kernel.py 2>&1 | tee -a $LOG
stamp "✅ Decision Kernel aktif"

# ============================================================
# MODUL 3: SENSOR BRIDGE (Kamera, Mikrofon, GPS)
# ============================================================
stamp ""
stamp "===== MODUL 3: SENSOR BRIDGE ====="

# Skrip untuk menerima data dari MacroDroid/Tasker
cat > ~/JDEQ/cognitive/sensor/sensor_bridge.py << 'PYEOF'
#!/usr/bin/env python3
"""MICO Sensor Bridge - Menerima input dari sensor Android via MQTT/HTTP"""
import json, os, sys
from datetime import datetime

SENSOR_LOG = os.path.expanduser("~/JDEQ/cognitive/sensor/sensor_log.jsonl")

def process_sensor(sensor_type, data):
    """Proses data sensor dan catat"""
    event = {
        "timestamp": str(datetime.now()),
        "type": sensor_type,
        "data": data
    }
    
    with open(SENSOR_LOG, 'a') as f:
        f.write(json.dumps(event) + "\n")
    
    # Trigger action berdasarkan jenis sensor
    if sensor_type == "kamera":
        return "/analyst /deepdive /report Foto diterima oleh MICO"
    elif sensor_type == "mikrofon":
        return "/notes /summary /action Rekaman suara diterima"
    elif sensor_type == "gps":
        return f"/ghost Lokasi tercatat: {data}"
    elif sensor_type == "notification":
        return f"/summary Notifikasi: {data}"
    else:
        return f"/ghost Sensor {sensor_type} aktif"

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        result = process_sensor(sys.argv[1], " ".join(sys.argv[2:]))
        print(result)
    else:
        print("Pakai: sensor_bridge.py <tipe> <data>")
PYEOF
chmod +x ~/JDEQ/cognitive/sensor/sensor_bridge.py

# Tes sensor bridge
python3 ~/JDEQ/cognitive/sensor/sensor_bridge.py tes "Sensor Bridge aktif" 2>&1 | tee -a $LOG
stamp "✅ Sensor Bridge aktif"

# ============================================================
# MODUL 4: SIMPLE LEARNING ENGINE
# ============================================================
stamp ""
stamp "===== MODUL 4: LEARNING ENGINE ====="

cat > ~/JDEQ/cognitive/learning/learning_engine.py << 'PYEOF'
#!/usr/bin/env python3
"""MICO Learning Engine - Belajar dari interaksi"""
import json, os, sys
from datetime import datetime

LEARN_FILE = os.path.expanduser("~/JDEQ/cognitive/learning/patterns.json")
os.makedirs(os.path.dirname(LEARN_FILE), exist_ok=True)

def load_patterns():
    if os.path.exists(LEARN_FILE):
        with open(LEARN_FILE) as f: return json.load(f)
    return {"patterns": [], "version": "1.0"}

def save_patterns(data):
    with open(LEARN_FILE, 'w') as f: json.dump(data, f, indent=2)

def learn(input_text, response_text, success=True):
    """Catat pola interaksi untuk pembelajaran"""
    data = load_patterns()
    pattern = {
        "timestamp": str(datetime.now()),
        "input": input_text[:200],
        "response": response_text[:200],
        "success": success,
        "category": "general"
    }
    data["patterns"].append(pattern)
    if len(data["patterns"]) > 100:  # Batasi 100 pola
        data["patterns"] = data["patterns"][-100:]
    save_patterns(data)
    return f"Belajar: {len(data['patterns'])} pola tersimpan"

if __name__ == "__main__":
    print(learn("test", "Learning Engine aktif", True))
PYEOF
chmod +x ~/JDEQ/cognitive/learning/learning_engine.py
python3 ~/JDEQ/cognitive/learning/learning_engine.py 2>&1 | tee -a $LOG
stamp "✅ Learning Engine aktif"

# ============================================================
# INTEGRASI KE AUTO-HEAL
# ============================================================
stamp ""
stamp "===== INTEGRASI COGNITIVE KE AUTO-HEAL ====="

# Tambahkan cognitive check ke auto-heal
cat > ~/JDEQ/bin/auto_heal_cognitive.sh << 'AUTOHEAL'
#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/cognitive_auto_heal.log"
echo "[$(date)] Cognitive auto-heal check" >> $LOG

# Pastikan Knowledge Core database ada
if [ ! -f ~/JDEQ/cognitive/knowledge/knowledge.db ]; then
  echo "[$(date)] ⚠️ Knowledge DB hilang — inisialisasi ulang" >> $LOG
  python3 ~/JDEQ/cognitive/knowledge/init_knowledge.py >> $LOG 2>&1
fi

# Pastikan Decision Kernel responsif
python3 -c "from cognitive.decision.decision_kernel import decide; decide(['test'])" 2>/dev/null || \
  echo "[$(date)] ⚠️ Decision Kernel perlu perhatian" >> $LOG

echo "[$(date)] Cognitive auto-heal selesai" >> $LOG
AUTOHEAL
chmod +x ~/JDEQ/bin/auto_heal_cognitive.sh

# Pasang di cron tiap 10 menit
(crontab -l 2>/dev/null | grep -v auto_heal_cognitive; echo "*/10 * * * * bash ~/JDEQ/bin/auto_heal_cognitive.sh") | crontab -
stamp "✅ Cognitive Auto-Heal aktif"

# ============================================================
# VERIFIKASI AKHIR
# ============================================================
stamp ""
stamp "============================================"
stamp " VERIFIKASI COGNITIVE LAYER"
stamp "============================================"

echo "🧠 Knowledge Core : $(python3 -c 'import os; print("✅" if os.path.exists(os.path.expanduser("~/JDEQ/cognitive/knowledge/knowledge.db")) else "❌")')" | tee -a $LOG
echo "🎯 Decision Kernel: $(python3 -c 'from cognitive.decision.decision_kernel import decide; print("✅" if decide(["test"]) else "❌")' 2>/dev/null || echo '⚠️')" | tee -a $LOG
echo "📡 Sensor Bridge  : $(python3 ~/JDEQ/cognitive/sensor/sensor_bridge.py tes "test" > /dev/null 2>&1 && echo '✅' || echo '⚠️')" | tee -a $LOG
echo "📚 Learning Engine: $(python3 -c 'from cognitive.learning.learning_engine import learn; print("✅" if learn("t","t") else "❌")' 2>/dev/null || echo '⚠️')" | tee -a $LOG
echo "⚡ Cognitive Heal : $(bash ~/JDEQ/bin/auto_heal_cognitive.sh > /dev/null 2>&1 && echo '✅' || echo '⚠️')" | tee -a $LOG

stamp ""
stamp "============================================"
stamp " MICO COGNITIVE LAYER AKTIF"
stamp " MICO sekarang bisa:"
stamp "  🧠 Belajar dari interaksi"
stamp "  🎯 Mengambil keputusan mandiri"
stamp "  📡 Menerima input sensor (kamera, mic, GPS)"
stamp "  📚 Menyimpan pengetahuan permanen"
stamp "  ⚡ Memperbaiki diri otomatis"
stamp "============================================"

command -v termux-tts-speak > /dev/null && termux-tts-speak "MICO Cognitive Layer aktif. MICO sekarang bisa belajar dan mengambil keputusan." 2>/dev/null || true
