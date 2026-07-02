#!/usr/bin/env python3
import json, hashlib, sqlite3, os
from datetime import datetime
from pathlib import Path

class ReferenceRouter:
    def __init__(self):
        self.db = Path.home() / "JDEQ/RUNTIME/metadata.db"
        os.makedirs(self.db.parent, exist_ok=True)
        self.c = sqlite3.connect(str(self.db))
        # Gunakan skema 9 kolom yang sama dengan Version Validator
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
    
    def register(self, id, ver, content, author="ReferenceRouter", source="Core", priority="NORMAL", schema_version="1.0"):
        h = hashlib.sha256(content.encode()).hexdigest()
        self.c.execute('INSERT OR REPLACE INTO meta VALUES (?,?,?,?,?,?,?,?,?)',
            (id, ver, h, author, str(datetime.now()), source, "true", priority, schema_version))
        self.c.commit()
        return {"status": "REGISTERED", "hash": h[:16]}
    
    def validate(self, id, content):
        row = self.c.execute('SELECT * FROM meta WHERE id=?', (id,)).fetchone()
        if not row:
            return {"status": "REJECTED", "reason": "NOT_FOUND"}
        if row[2] != hashlib.sha256(content.encode()).hexdigest():
            return {"status": "REJECTED", "reason": "HASH_MISMATCH"}
        return {"status": "APPROVED", "version": row[1]}
