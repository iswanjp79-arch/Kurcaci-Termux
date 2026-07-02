import os, json
from datetime import datetime

JDEQ = "/data/data/com.termux/files/home/JDEQ"
MEMORY_LOG = os.path.join(JDEQ, "CORE_KNOWLEDGE/logs/knowledge_memory.json")

def record_knowledge(source, category, knowledge, validation="PENDING"):
    """Catat pengetahuan baru ke memory."""
    entry = {
        "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "source": source,
        "category": category,
        "knowledge": knowledge[:500],  # batasi 500 karakter
        "validation": validation
    }
    
    data = []
    if os.path.isfile(MEMORY_LOG):
        with open(MEMORY_LOG) as f:
            data = json.load(f)
    data.append(entry)
    
    with open(MEMORY_LOG, "w") as f:
        json.dump(data, f, indent=2, default=str)
    
    print(f"[MEMORY] {source} → {category} ({validation})")
    return entry

if __name__ == "__main__":
    record_knowledge("RAB_Test", "civil/rab", "Template RAB standar JDEQ", "PASS")
    record_knowledge("knowledge_loader.py", "system", "Knowledge Engine aktif", "PASS")
