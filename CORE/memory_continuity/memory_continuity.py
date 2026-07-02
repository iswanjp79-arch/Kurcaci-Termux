#!/usr/bin/env python3
"""Memory Continuity — Mengingat keadaan sebelumnya."""
import json
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
MEMORY_FILE = JDEQ / "state" / "continuity_memory.jsonl"

class MemoryContinuity:
    def __init__(self):
        self.memory = self._load()
    
    def _load(self):
        if MEMORY_FILE.exists():
            return [json.loads(line) for line in MEMORY_FILE.read_text().splitlines() if line]
        return []
    
    def remember(self, what, detail=""):
        entry = {"timestamp": str(datetime.now()), "what": what, "detail": detail}
        self.memory.append(entry)
        MEMORY_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(MEMORY_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")
        return entry
    
    def last_known(self, what=None):
        if what:
            return next((m for m in reversed(self.memory) if m["what"] == what), None)
        return self.memory[-1] if self.memory else None

if __name__ == "__main__":
    mc = MemoryContinuity()
    mc.remember("boot", "MICO baru saja dinyalakan")
    mc.remember("task_started", "Mengerjakan bundle final")
    print("Memori terakhir:", mc.last_known())
