import json, hashlib, os, sqlite3
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
    
    def _init_db(self):
        self.conn.execute("""CREATE TABLE IF NOT EXISTS metadata (
            id TEXT PRIMARY KEY, version TEXT, timestamp TEXT,
            hash TEXT, author TEXT DEFAULT 'MICO',
            verified INTEGER DEFAULT 0, source TEXT DEFAULT 'SSOT',
            priority INTEGER DEFAULT 1)""")
        self.conn.commit()
    def validate_document(self, doc_id, content):
        result = {"status": "PENDING", "document_id": doc_id}
        row = self.conn.execute("SELECT * FROM metadata WHERE id = ?", (doc_id,)).fetchone()
        if not row:
            result["status"] = "REJECTED"
            self._audit(doc_id, "REJECTED", "METADATA_NOT_FOUND")
            return result
        stored_hash = row[3]
        if hashlib.sha256(content.encode()).hexdigest() != stored_hash:
            result["status"] = "REJECTED"
            self._audit(doc_id, "REJECTED", "HASH_MISMATCH")
            return result
        result["status"] = "APPROVED"
        self._audit(doc_id, "APPROVED", f"Version: {row[1]}")
        return result
    
    def register_metadata(self, doc_id, version, content, source="SSOT", priority=1):
        doc_hash = hashlib.sha256(content.encode()).hexdigest()
        self.conn.execute("INSERT OR REPLACE INTO metadata VALUES (?,?,?,?,?,?,?,?)",
            (doc_id, version, str(datetime.now()), doc_hash, "MICO", 1, source, priority))
        self.conn.commit()
        return {"status": "REGISTERED", "id": doc_id, "version": version, "hash": doc_hash[:16]}
    def _audit(self, doc_id, status, reason=""):
        entry = {"time": str(datetime.now()), "actor": "ReferenceRouter",
                 "document": doc_id, "decision": status, "result": reason}
        with open(AUDIT_LOG, "a") as f:
            f.write(json.dumps(entry) + "\n")

if __name__ == "__main__":
    router = ReferenceRouter()
    content = "MICO-JDEQ Blueprint V7"
    reg = router.register_metadata("BLUEPRINT_V7", "7.0.0", content)
    print(f"✅ Register: {reg['hash']}")
    val = router.validate_document("BLUEPRINT_V7", content)
    print(f"✅ Validasi: {val['status']}")
