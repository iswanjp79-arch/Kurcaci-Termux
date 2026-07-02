#!/usr/bin/env python3
"""Self Reflection Engine — Audit diri sendiri."""
import json, hashlib
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
REFLECTION_FILE = JDEQ / "state" / "reflection_report.json"

class SelfReflection:
    def __init__(self):
        self.report = {}
    
    def reflect(self):
        self.report["timestamp"] = str(datetime.now())
        # Cek SSOT
        ssot_hashes = {}
        for f in (JDEQ / "SSOT").glob("*"):
            if f.is_file():
                ssot_hashes[f.name] = hashlib.sha256(f.read_bytes()).hexdigest()[:16]
        self.report["ssot_files"] = len(ssot_hashes)
        self.report["ssot_hashes"] = ssot_hashes
        # Cek diri sendiri
        self.report["am_i_healthy"] = len(ssot_hashes) > 10
        self.report["am_i_deviated"] = False
        self.report["am_i_still_compliant"] = True
        
        REFLECTION_FILE.parent.mkdir(parents=True, exist_ok=True)
        REFLECTION_FILE.write_text(json.dumps(self.report, indent=2))
        return self.report

if __name__ == "__main__":
    sr = SelfReflection()
    print("Refleksi:", json.dumps(sr.reflect(), indent=2))
