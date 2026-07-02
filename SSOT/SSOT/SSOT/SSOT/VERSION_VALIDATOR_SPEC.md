# MICO-JDEQ VERSION VALIDATOR — SPESIFIKASI (Stage 5A)
**Versi:** 1.0
**Status:** ⚪ BELUM TERBUKTI (Menunggu Audit)
**Auditor:** DeepSeek (Executor) & ChatGPT (Chief Architect)

## 1. Tujuan
Version Validator memastikan setiap komponen yang berjalan di MICO‑JDEQ memiliki versi yang sah, hash yang terverifikasi, dan timestamp yang tercatat. Ia menolak komponen dengan versi lebih rendah atau hash yang tidak cocok.

## 2. API Publik
```python
def register(module_id: str, version: str, hash_sha256: str) -> dict:
    """Mendaftarkan modul dengan versi dan hash. Mengembalikan status REGISTERED."""

def validate(module_id: str, version: str, hash_sha256: str) -> dict:
    """Memvalidasi versi dan hash modul. Mengembalikan APPROVED atau REJECTED."""
REGISTER → VALIDATE → APPROVED / REJECTED
cat > ~/JDEQ/CORE/version_validator/version_validator.py << 'EOF'
#!/usr/bin/env python3
import sqlite3, json, hashlib, os
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
DB_PATH = JDEQ / "RUNTIME" / "metadata.db"
AUDIT_LOG = JDEQ / "AUDIT" / "version_validator.jsonl"
os.makedirs(DB_PATH.parent, exist_ok=True)
os.makedirs(AUDIT_LOG.parent, exist_ok=True)

class VersionValidator:
    def __init__(self):
        self.c = sqlite3.connect(str(DB_PATH))
        self.c.execute('''CREATE TABLE IF NOT EXISTS meta (
            id TEXT PRIMARY KEY,
            version TEXT,
            hash_sha256 TEXT,
            author TEXT,
            timestamp TEXT,
            source TEXT,
            verified TEXT,
            priority TEXT,
            schema_version TEXT
        )''')
        self.c.commit()

    def _audit(self, module_id, version, status, detail=""):
        entry = {
            "timestamp": datetime.now().isoformat(),
            "module_id": module_id,
            "version": version,
            "status": status,
            "detail": detail
        }
        with open(AUDIT_LOG, "a") as f:
            f.write(json.dumps(entry) + "\n")

    def register(self, module_id, version, hash_sha256, author="unknown", source="unknown", priority="NORMAL", schema_version="1.0"):
        """Mendaftarkan modul. Mencegah downgrade versi."""
        row = self.c.execute('SELECT version, hash_sha256 FROM meta WHERE id=?', (module_id,)).fetchone()
        
        if row:
            # Sudah terdaftar: periksa downgrade
            if version < row[0]:
                self._audit(module_id, version, "VERSION_DOWNGRADE", f"Existing: {row[0]}")
                return {"status": "REJECTED", "reason": "VERSION_DOWNGRADE"}
            # Versi sama: hash harus identik
            if version == row[0] and hash_sha256 != row[1]:
                self._audit(module_id, version, "HASH_MISMATCH", f"Expected: {row[1]}")
                return {"status": "REJECTED", "reason": "HASH_MISMATCH"}
            # Versi sama, hash sama: DUPLICATE
            if version == row[0] and hash_sha256 == row[1]:
                self._audit(module_id, version, "DUPLICATE", "Already registered with same hash")
                return {"status": "REGISTERED", "reason": "DUPLICATE"}

        # Insert atau update
        self.c.execute('INSERT OR REPLACE INTO meta VALUES (?,?,?,?,?,?,?,?,?)',
            (module_id, version, hash_sha256, author, datetime.now().isoformat(), source, "true", priority, schema_version))
        self.c.commit()
        self._audit(module_id, version, "REGISTERED")
        return {"status": "REGISTERED", "module_id": module_id, "version": version}

    def validate(self, module_id, version, hash_sha256):
        """Memvalidasi modul terhadap registry."""
        row = self.c.execute('SELECT version, hash_sha256 FROM meta WHERE id=?', (module_id,)).fetchone()
        
        if not row:
            self._audit(module_id, version, "NOT_FOUND")
            return {"status": "REJECTED", "reason": "NOT_FOUND"}
        
        if version < row[0]:
            self._audit(module_id, version, "VERSION_DOWNGRADE")
            return {"status": "REJECTED", "reason": "VERSION_DOWNGRADE"}
        
        if hash_sha256 != row[1]:
            self._audit(module_id, version, "HASH_MISMATCH")
            return {"status": "REJECTED", "reason": "HASH_MISMATCH"}
        
        self._audit(module_id, version, "APPROVED")
        return {"status": "APPROVED", "version": row[0]}
