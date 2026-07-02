#!/usr/bin/env python3
"""Evidence Policy — Standar bukti untuk setiap modul"""
import json, os, hashlib
from datetime import datetime
from pathlib import Path

EVIDENCE_DB = Path.home() / "JDEQ/RUNTIME/evidence.db"

class EvidencePolicy:
    def __init__(self):
        self.required_fields = [
            "module_name", "implementation_file", "unit_test", 
            "integration_test", "metadata_hash", "version",
            "audit_log", "reproducible"
        ]
    
    def validate_evidence(self, module_name, evidence):
        """Validasi kelengkapan bukti untuk suatu modul"""
        missing = [f for f in self.required_fields if f not in evidence]
        if missing:
            return {"status": "BELUM_TERBUKTI", "missing_fields": missing}
        
        # Verifikasi hash
        if evidence.get("implementation_file"):
            file_path = Path.home() / evidence["implementation_file"]
            if file_path.exists():
                file_hash = hashlib.sha256(file_path.read_text().encode()).hexdigest()[:16]
                if file_hash != evidence.get("metadata_hash", ""):
                    return {"status": "BELUM_TERBUKTI", "reason": "HASH_MISMATCH"}
        
        return {"status": "TERBUKTI", "module": module_name, "timestamp": str(datetime.now())}
    
    def record_evidence(self, module_name, evidence):
        """Catat bukti ke log"""
        log_file = Path.home() / "JDEQ/logs/evidence.log"
        with open(log_file, "a") as f:
            f.write(json.dumps({"module": module_name, "evidence": evidence, "time": str(datetime.now())}) + "\n")
        return {"status": "RECORDED"}

if __name__ == "__main__":
    ep = EvidencePolicy()
    test_evidence = {
        "module_name": "sovereign_kernel",
        "implementation_file": "CORE/sovereign_kernel/kernel.py",
        "unit_test": "PASS",
        "integration_test": "PASS",
        "metadata_hash": "test_hash",
        "version": "7.1.0",
        "audit_log": "ACTIVE",
        "reproducible": True
    }
    result = ep.validate_evidence("sovereign_kernel", test_evidence)
    print(f"✅ Evidence Policy: {result['status']}")
