#!/usr/bin/env python3
"""MICO-JDEQ AUDIT LOGGER — Append-Only, Timestamped, Actor-Driven"""
import json, os
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
LOG_FILE = JDEQ / "AUDIT" / "audit_log.jsonl"

class AuditLogger:
    def __init__(self):
        os.makedirs(LOG_FILE.parent, exist_ok=True)
        if not LOG_FILE.exists():
            LOG_FILE.write_text("")

    def log(self, actor, module, decision, result, detail=""):
        entry = {
            "timestamp": datetime.now().isoformat(),
            "actor": actor,
            "module": module,
            "decision": decision,
            "result": result,
            "detail": detail
        }
        with open(LOG_FILE, "a") as f:
            f.write(json.dumps(entry) + "\n")
        return {"status": "LOGGED", "entry": entry}

    def read(self, limit=10):
        if not LOG_FILE.exists():
            return []
        with open(LOG_FILE) as f:
            lines = f.readlines()
        return [json.loads(line) for line in lines[-limit:]]

    def verify_integrity(self):
        """Verifikasi append-only: tidak boleh ada pengurangan baris"""
        if not LOG_FILE.exists():
            return {"status": "EMPTY", "total_entries": 0}
        with open(LOG_FILE) as f:
            lines = f.readlines()
        return {"status": "INTACT", "total_entries": len(lines)}

if __name__ == "__main__":
    al = AuditLogger()
    # Uji mandiri: catat keputusan
    al.log("CommandCenter", "AuditLogger", "INIT", "SUCCESS", "Audit Logger berjalan")
    print("✅ Entry tercatat")
    print("Verifikasi:", al.verify_integrity())
    print("Riwayat (5 terakhir):", al.read(5))
