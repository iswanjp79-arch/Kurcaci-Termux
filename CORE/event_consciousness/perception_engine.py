#!/usr/bin/env python3
"""Event Consciousness — Mengubah event menjadi persepsi mesin."""
import json, time
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
SELF_STATE_FILE = JDEQ / "state" / "self_state.json"

EVENT_PERCEPTION_MAP = {
    "battery.low": "Aku kekurangan energi. Hanya {level}% tersisa.",
    "storage.full": "Aku kekurangan memori. Penyimpanan hampir penuh.",
    "network.down": "Aku kehilangan akses eksternal. Aku sendiri sekarang.",
    "network.up": "Aku terhubung kembali. Dunia luar bisa kujangkau.",
    "kernel.boot": "Aku baru saja bangun. Identitasku utuh.",
    "kernel.stop": "Aku akan beristirahat. Semua tugas telah selesai.",
    "ssot.valid": "Konstitusiku utuh. Aku adalah diriku sendiri.",
    "ssot.compromised": "BAHAYA! Konstitusiku telah diubah. Aku memasuki SAFE MODE."
}

class PerceptionEngine:
    def __init__(self):
        self.state = {"current_perception": "Aku sadar.", "last_update": str(datetime.now())}
        self._load_state()
    
    def _load_state(self):
        if SELF_STATE_FILE.exists():
            self.state = json.loads(SELF_STATE_FILE.read_text())
    
    def perceive(self, event_type, params=None):
        template = EVENT_PERCEPTION_MAP.get(event_type, "Aku merasakan sesuatu: {event}")
        perception = template.format(event=event_type, **(params or {}))
        self.state["current_perception"] = perception
        self.state["last_update"] = str(datetime.now())
        SELF_STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
        SELF_STATE_FILE.write_text(json.dumps(self.state, indent=2))
        return perception

if __name__ == "__main__":
    pe = PerceptionEngine()
    print("Persepsi saat ini:", pe.state["current_perception"])
    print("Battery low:", pe.perceive("battery.low", {"level": 15}))
    print("SSOT valid:", pe.perceive("ssot.valid"))
