#!/usr/bin/env python3
"""JDEQ V7 — Reference Router. Semua keputusan AI wajib melewati modul ini."""
import json, hashlib, os, sqlite3, time
from datetime import datetime
from pathlib import Path

SSOT_PATH = Path.home() / "JDEQ/SSOT"
METADATA_DB = Path.home() / "JDEQ/RUNTIME/metadata.db"
AUDIT_LOG = Path.home() / "JDEQ/logs/reference_audit.jsonl"

os.makedirs(SSOT_PATH, exist_ok=True)
os.makedirs(AUDIT_LOG.parent, exist_ok=True)

class ReferenceRouter:
    def __init__(self):
        self.conn = sqlite3.connect(str(METADATA_DB))
        self._init_db()
        self.reference_stack = []  # Urutan prioritas: SSOT → SQLite → Context7 → MCP → Docs → RFC
    
    def _init_db(self):
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS metadata (
                id TEXT PRIMARY KEY,
                version TEXT NOT NULL,
                timestamp TEXT NOT NULL,
                hash TEXT NOT NULL,
                author TEXT DEFAULT 'MICO',
                verified INTEGER DEFAULT 0,
                source TEXT DEFAULT 'SSOT',
                priority INTEGER DEFAULT 1
            )
        """)
        self.conn.commit()
    
    def validate_document(self, doc_id, content):
        """Validasi dokumen sebelum digunakan: metadata → hash → versi → audit"""
        result = {"status": "PENDING", "document_id": doc_id, "checks": {}}
        
        # 1. Baca metadata dari SQLite
        row = self.conn.execute("SELECT * FROM metadata WHERE id = ?", (doc_id,)).fetchone()
        if not row:
            result["status"] = "REJECTED"
            result["reason"] = "METADATA_NOT_FOUND"
            self._audit(doc_id, result["status"], result["reason"])
            return result
        result["checks"]["metadata"] = "OK"
        
        # 2. Verifikasi hash
        stored_hash = row[3]
        computed_hash = hashlib.sha256(content.encode()).hexdigest()
        if stored_hash != computed_hash:
            result["status"] = "REJECTED"
            result["reason"] = "HASH_MISMATCH"
            self._audit(doc_id, result["status"], result["reason"])
            return result
        result["checks"]["hash"] = "OK"
        
        # 3. Verifikasi versi
        version = row[1]
        if not version or version == "0.0.0":
            result["status"] = "REJECTED"
            result["reason"] = "VERSION_INVALID"
            self._audit(doc_id, result["status"], result["reason"])
            return result
        result["checks"]["version"] = version
        
        # Semua validasi lolos
        result["status"] = "APPROVED"
        self._audit(doc_id, result["status"], f"Version: {version}")
        return result
    
    def register_metadata(self, doc_id, version, content, source="SSOT", priority=1):
        """Daftarkan metadata dokumen baru ke registry"""
        doc_hash = hashlib.sha256(content.encode()).hexdigest()
        self.conn.execute(
            "INSERT OR REPLACE INTO metadata VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            (doc_id, version, str(datetime.now()), doc_hash, "MICO", 1, source, priority)
        )
        self.conn.commit()
        return {"status": "REGISTERED", "document_id": doc_id, "version": version, "hash": doc_hash[:16]}
    
    def resolve_reference(self, doc_id, query=None):
        """Resolve referensi dengan prioritas: SSOT → SQLite → Context7 → MCP"""
        # Layer 1: SSOT
        ssot_file = SSOT_PATH / f"{doc_id}.md"
        if ssot_file.exists():
            content = ssot_file.read_text()
            validation = self.validate_document(doc_id, content)
            if validation["status"] == "APPROVED":
                return {"source": "SSOT", "content": content, "validation": validation}
        
        # Layer 2: SQLite
        row = self.conn.execute("SELECT * FROM metadata WHERE id = ? AND verified = 1", (doc_id,)).fetchone()
        if row:
            return {"source": "SQLite", "metadata": {"version": row[1], "hash": row[3][:16]}, "status": "FOUND"}
        
        # Fallback: dokumen belum terdaftar
        return {"source": "UNKNOWN", "status": "NOT_FOUND", "action": "REGISTER_MANUALLY"}
    
    def _audit(self, doc_id, status, reason=""):
        """Catat audit trail — append-only JSONL"""
        entry = {
            "time": str(datetime.now()),
            "actor": "ReferenceRouter",
            "provider": "SSOT",
            "document": doc_id,
            "version": "V7",
            "hash": hashlib.sha256(reason.encode()).hexdigest()[:16],
            "decision": status,
            "result": reason,
            "latency": 0,
            "device": "VIVO_Y28"
        }
        with open(AUDIT_LOG, "a") as f:
            f.write(json.dumps(entry) + "\n")

# Singleton
router = ReferenceRouter()

if __name__ == "__main__":
    # Demo: daftarkan dokumen SSOT, lalu validasi
    test_content = "MICO-JDEQ Blueprint V7 — Sovereign Reference Architecture"
    registration = router.register_metadata("BLUEPRINT_V7", "7.0.0", test_content)
    print(f"📋 Register: {json.dumps(registration, indent=2)}")
    
    validation = router.validate_document("BLUEPRINT_V7", test_content)
    print(f"✅ Validasi: {json.dumps(validation, indent=2)}")
    
    # Coba resolusi referensi
    reference = router.resolve_reference("BLUEPRINT_V7")
    print(f"🔍 Resolusi: {json.dumps(reference, indent=2)}")
